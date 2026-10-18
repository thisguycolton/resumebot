# syntax=docker/dockerfile:1
# Production image for CapRover (or anything that runs Docker).
#   docker build -t portfolio .
#   docker run -p 8080:80 -e SECRET_KEY_BASE=$(openssl rand -hex 64) -e SITE_URL=http://localhost:8080 portfolio
#
# Memory: the front end is built in its own small Node stage, with the Node heap
# capped, so the build stays well under 1 GB. If your CapRover server still runs
# out of memory, build the image elsewhere and deploy it as an image (see README).

ARG RUBY_VERSION=3.3.6
ARG NODE_VERSION=22

# ---- Front end: Vite + Tailwind only, no Ruby ------------------------------
FROM docker.io/library/node:${NODE_VERSION}-slim AS frontend
WORKDIR /rails
ENV NODE_OPTIONS=--max-old-space-size=768
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY vite.config.mjs ./
COPY config/vite.json config/vite.json
COPY app/frontend app/frontend
RUN npx vite build

# ---- Ruby base --------------------------------------------------------------
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base
WORKDIR /rails
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libpq5 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# ---- Gems -------------------------------------------------------------------
FROM base AS build
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile
COPY . .
RUN bundle exec bootsnap precompile app/ lib/

# ---- Final image ------------------------------------------------------------
FROM base
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails
COPY --from=frontend /rails/public/vite /rails/public/vite

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p log tmp && \
    chown -R rails:rails log tmp
USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Thruster serves public/ files with compression and caching, then proxies to Puma.
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
