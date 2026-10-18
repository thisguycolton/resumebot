# Everything the page says, in one object.
#
# The raw copy lives in config/portfolio.yml. This class cleans it up
# (blank values become nil, share URLs become embed URLs, links get their
# mailto: prefix) and hands the result to Inertia as props.
#
# To swap in a CMS, replace SiteContent.read_source. That is the only place
# that knows where the content comes from. See "Plugging in a CMS" in README.md.
class SiteContent
  SOURCE = Rails.root.join("config/portfolio.yml")

  YOUTUBE_HOSTS = %w[youtube.com www.youtube.com m.youtube.com youtu.be].freeze
  LOOM_HOSTS = %w[loom.com www.loom.com].freeze
  VIDEO_ID = /\A[\w-]+\z/

  # CMS seam: return a Hash with the same shape as config/portfolio.yml.
  def self.read_source
    YAML.safe_load_file(SOURCE, aliases: false)
  end

  def self.load(site_url: Rails.configuration.x.site_url)
    new(read_source, site_url: site_url)
  end

  def initialize(source, site_url:)
    @source = blank_to_nil(source).deep_symbolize_keys
    @site_url = site_url.to_s.chomp("/")
  end

  # Props for the Inertia page. Page metadata goes to the layout, not React.
  def props
    {
      ui: @source[:ui],
      person: person,
      video: video,
      projects_heading: @source[:projects_heading],
      projects: projects,
      about: @source[:about]
    }
  end

  # Tags for <head>: title, description and Open Graph.
  def meta
    meta = @source[:meta]
    {
      title: meta[:title],
      description: meta[:description].to_s.squish,
      site_name: person[:name],
      canonical_url: "#{@site_url}/",
      image_url: absolute_url(meta[:og_image]),
      image_alt: meta[:og_image_alt]
    }
  end

  private

  def person
    @person ||= begin
      person = @source[:person]
      person.merge(email_href: "mailto:#{person[:email]}")
    end
  end

  def projects
    Array(@source[:projects]).map do |project|
      project.merge(features: Array(project[:features]), stack: Array(project[:stack]))
    end
  end

  def video
    video = @source[:video]
    media = video_media(video[:url])
    video.except(:url).merge(media: media, poster: media&.fetch(:kind) == "file" ? video[:poster] : nil)
  end

  # Turns a YouTube/Loom share URL or an mp4 path into something the page can
  # play. Anything we do not recognise is ignored, so the placeholder shows
  # instead of an arbitrary iframe.
  def video_media(url)
    return if url.blank?

    return { kind: "file", src: url } if url.start_with?("/") || url.match?(/\.mp4(\?.*)?\z/i)

    uri = URI.parse(url)
    id =
      if YOUTUBE_HOSTS.include?(uri.host)
        youtube_id(uri)
      elsif LOOM_HOSTS.include?(uri.host)
        uri.path[%r{\A/(?:share|embed)/([\w-]+)}, 1]
      end
    return unless id&.match?(VIDEO_ID)

    host = LOOM_HOSTS.include?(uri.host) ? "https://www.loom.com/embed" : "https://www.youtube-nocookie.com/embed"
    { kind: "embed", src: "#{host}/#{id}" }
  rescue URI::InvalidURIError
    nil
  end

  def youtube_id(uri)
    return uri.path.delete_prefix("/") if uri.host == "youtu.be"

    uri.path[%r{\A/(?:embed|shorts|live)/([\w-]+)}, 1] || Rack::Utils.parse_query(uri.query.to_s)["v"]
  end

  def absolute_url(path)
    return if path.blank?

    path.start_with?("http") ? path : "#{@site_url}#{path}"
  end

  def blank_to_nil(value)
    case value
    when Hash then value.transform_values { |v| blank_to_nil(v) }
    when Array then value.map { |v| blank_to_nil(v) }
    when String then value.strip.presence
    else value
    end
  end
end
