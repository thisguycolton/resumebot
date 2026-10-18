require "test_helper"

class SiteContentTest < ActiveSupport::TestCase
  def content(overrides = {})
    source = SiteContent.read_source.deep_dup
    overrides.each { |path, value| set_path(source, path.to_s.split("."), value) }
    SiteContent.new(source, site_url: "https://example.test/")
  end

  def video_for(url)
    content("video.url" => url).props[:video]
  end

  test "builds the mailto link and keeps the email" do
    person = content.props[:person]

    assert_equal "mailto:coltonhagan@gmail.com", person[:email_href]
    assert_equal "coltonhagan@gmail.com", person[:email]
  end

  test "treats blank values as unset" do
    props = content("person.linkedin_url" => "  ", "projects.0.code_url" => "").props

    assert_nil props[:person][:linkedin_url]
    assert_nil props[:projects].first[:code_url]
  end

  test "shows a LinkedIn link only once it is set" do
    url = "https://www.linkedin.com/in/example"

    assert_equal url, content("person.linkedin_url" => url).props[:person][:linkedin_url]
  end

  test "meta uses the configured site URL without a double slash" do
    meta = content.meta

    assert_equal "https://example.test/", meta[:canonical_url]
    assert_equal "https://example.test/images/og.png", meta[:image_url]
    assert_not_includes meta[:description], "\n"
  end

  test "no video url means no media" do
    assert_nil video_for(nil)[:media]
  end

  test "converts YouTube urls to privacy-friendly embeds" do
    [
      "https://www.youtube.com/watch?v=abc123_-XYZ&t=5",
      "https://youtu.be/abc123_-XYZ",
      "https://www.youtube.com/shorts/abc123_-XYZ",
      "https://www.youtube.com/embed/abc123_-XYZ"
    ].each do |url|
      assert_equal({ kind: "embed", src: "https://www.youtube-nocookie.com/embed/abc123_-XYZ" }, video_for(url)[:media], url)
    end
  end

  test "converts Loom share urls to embeds" do
    media = video_for("https://www.loom.com/share/0123456789abcdef")[:media]

    assert_equal({ kind: "embed", src: "https://www.loom.com/embed/0123456789abcdef" }, media)
  end

  test "plays mp4 files from public/ and keeps their poster" do
    video = content("video.url" => "/demo.mp4", "video.poster" => "/demo.webp").props[:video]

    assert_equal({ kind: "file", src: "/demo.mp4" }, video[:media])
    assert_equal "/demo.webp", video[:poster]
  end

  test "ignores urls it does not recognise" do
    [ "https://evil.example/watch?v=abc", "https://www.youtube.com/watch", "not a url", "https://www.youtube.com/watch?v=a b" ].each do |url|
      assert_nil video_for(url)[:media], url
    end
  end

  private

  def set_path(hash, keys, value)
    *parents, last = keys
    target = parents.inject(hash) { |node, key| node.is_a?(Array) ? node[key.to_i] : node[key] }
    target.is_a?(Array) ? target[last.to_i] = value : target[last] = value
  end
end
