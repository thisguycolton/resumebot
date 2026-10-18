# Portfolio

One-page portfolio for Colton Hagan, full stack developer. Rails 8 + Inertia Rails + React + Vite +
Tailwind CSS 4, on PostgreSQL, deployed as a Docker image on CapRover.

The page is fast and plain on purpose: one route, no analytics, no cookies, no contact form,
system fonts, and a ~108 KB gzipped JavaScript bundle (React + Inertia).

## Setup

You need Ruby 3.3.6, Node 22 and PostgreSQL.

```sh
bundle install
npm install
bin/rails db:create     # the page doesn't use the database yet, but Rails' test setup connects to it
bin/dev                 # Rails on :3000 and Vite
```

Open http://localhost:3000.

```sh
bin/rails test          # request and content tests (builds the front end on first run)
bin/rubocop             # lint
bin/brakeman --no-pager # security scan
```

CI (`.github/workflows/ci.yml`) runs all three, plus the production Docker build and a boot check of the image.

## Editing content

**Everything visitors read lives in [`config/portfolio.yml`](config/portfolio.yml).** There is no copy in the
React components, so a text change is a YAML change plus a redeploy.

| To change | Edit |
| --- | --- |
| Name, role, location, email, GitHub | `person:` |
| Show the LinkedIn link in the footer | set `person.linkedin_url` (blank = hidden) |
| Add the demo video | set `video.url` (blank = placeholder) |
| Add the metr. "Code" button | set `code_url` on the metr. project (blank = hidden) |
| Projects, features, tech tags | `projects:` |
| About text | `about.body` |
| Button and heading labels | `ui:` |
| Title, description, link preview | `meta:` |

### Demo video

Set `video.url` to one of:

- a YouTube link (`https://www.youtube.com/watch?v=...`, `youtu.be/...`, or a Shorts link). It plays through
  `youtube-nocookie.com`, so no cookies are set until someone presses play.
- a Loom share link (`https://www.loom.com/share/...`)
- an mp4 in `public/`, for example `/demo.mp4`. Add `video.poster: /demo.webp` for a poster frame.

Any other URL is ignored and the placeholder shows, so a typo can't embed something unexpected.

### Files you supply

| File | Notes |
| --- | --- |
| `public/images/metr.webp` | Screenshot, 1600×1000 (16:10), WebP. A placeholder ships now. |
| `public/images/recoverybot.webp` | Same. |
| `public/resume.pdf` | Your résumé. A placeholder ships now. |
| `public/images/og.png` | The link-preview card (1200×630). PNG on purpose: LinkedIn, Slack and email clients don't reliably render WebP previews. Replace it if you want different art. |

Replacing a file keeps its name, so nothing else changes. Public files are cached for an hour.

## Plugging in a CMS

The page is built from one Ruby object, [`SiteContent`](app/models/site_content.rb), which turns raw content into
Inertia props (and the `<head>` tags). Where the raw content comes from is a single method:

```ruby
# app/models/site_content.rb
def self.read_source
  YAML.safe_load_file(SOURCE, aliases: false)
end
```

To use the Tiptap CMS from RecoveryBot, change **only that method** so it returns a Hash shaped like
`config/portfolio.yml` (same keys), for example by reading rows from the database and assembling them.
The controller, the React page and the tests that check props keep working. Things to know:

- Rich text: today `about.body` and the feature lists are plain strings. If the CMS stores Tiptap/HTML,
  sanitize it on the server and render it in the component with `dangerouslySetInnerHTML`.
- `SiteContent.load` runs on every request, so add `Rails.cache` inside `read_source` if the CMS is slow.
- The database is already wired up (`config/database.yml`, `pg`); `bin/docker-entrypoint` has a note about
  where to add `bin/rails db:prepare`.

## Deploying to CapRover

The repo has a production `Dockerfile` and a `captain-definition`. The container serves on port 80
(Thruster in front of Puma), and `/up` is the health check.

1. **Create the app.** In CapRover, Apps → create a new app, for example `portfolio`. Leave "Has Persistent Data" off.
2. **Connect the domain.** On the app's HTTP Settings, enter `colton.hmblbot.com` under "Connect New Domain".
   Point a DNS `A` record for `colton` (or a wildcard `*.hmblbot.com`) at the CapRover server.
3. **Enable HTTPS.** Click "Enable HTTPS" for the domain, then tick "Force HTTPS by redirecting all HTTP traffic".
4. **Set environment variables** (App Configs):

   | Variable | Value |
   | --- | --- |
   | `SECRET_KEY_BASE` | output of `bin/rails secret` (required) |
   | `SITE_URL` | `https://colton.hmblbot.com` (the public URL; used for canonical and Open Graph tags, and as the only host Rails answers to) |
   | `ALLOWED_HOSTS` | optional, comma-separated extra hosts (for example `www.coltonhagan.com`) |
   | `RAILS_LOG_LEVEL` | optional, default `info` |

   No database variables are needed while the page is served from the YAML file.
5. **Deploy.** Any one of:
   - CapRover CLI from this repo: `caprover deploy`
   - connect the GitHub repo under Deployment → "Method 3" and use the webhook, or
   - the image method below.

   Then check `https://colton.hmblbot.com/up` and the page itself.

### If the build runs out of memory

The front end builds in its own Node stage with the Node heap capped at 768 MB, and no Ruby is loaded while it
runs, so the build should be light. If CapRover still runs out of memory, build the image on another machine
(your laptop or CI) and deploy it as an image:

```sh
# on a machine with Docker and enough memory
docker build -t registry.example.com/you/portfolio:1 .
docker push registry.example.com/you/portfolio:1
```

Then in CapRover, the app's Deployment tab → "Method 4: Deploy via ImageName" (or "Deploy via Docker image" with a
private-registry login under Cluster → Docker Registry Configuration), and enter
`registry.example.com/you/portfolio:1`. Or, without a registry, use `docker save portfolio | gzip > portfolio.tar.gz`
and the "Method 5: tarball" upload. Environment variables above are set in CapRover either way.

### Switching to coltonhagan.com later

1. Add `coltonhagan.com` as a domain on the same CapRover app, point its DNS `A` record at the server,
   and enable HTTPS for it.
2. Change `SITE_URL` to `https://coltonhagan.com`.
3. Redeploy (or just restart the app).

No code changes. Keep the old host in `ALLOWED_HOSTS` while links to it are still out there.

## Notes

- **Rendering:** the page is rendered by React in the browser (Inertia without SSR). Link previews work because
  the title, description and Open Graph tags are rendered by Rails in the HTML head. If you ever want
  server-rendered body HTML, Inertia SSR is the upgrade path.
- **No cookies:** no sessions, no CSRF tag, no analytics, and YouTube uses the no-cookie domain.
- **Screenshots** of the page at phone and desktop widths in light and dark mode are in `docs/screenshots/`.
