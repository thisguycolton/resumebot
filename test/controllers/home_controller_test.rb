require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @content = YAML.safe_load_file(Rails.root.join("config/portfolio.yml"))
  end

  test "renders the Home component with props from the content file" do
    get root_path

    assert_response :success
    assert_inertia_component "Home"

    person = @content["person"]
    props = inertia.props
    assert_equal person["name"], props.dig(:person, :name)
    assert_equal person["role"], props.dig(:person, :role)
    assert_equal "mailto:#{person['email']}", props.dig(:person, :email_href)
    assert_equal person["github_url"], props.dig(:person, :github_url)
    assert_equal person["resume_path"], props.dig(:person, :resume_path)
    assert_equal @content["about"]["body"].squish, props.dig(:about, :body)
  end

  test "passes every project from the content file, in order" do
    get root_path

    projects = inertia.props[:projects]
    assert_equal @content["projects"].map { |p| p["slug"] }, projects.map { |p| p[:slug] }
    assert_equal %w[metr. RecoveryBot], projects.map { |p| p[:name] }
    assert projects.all? { |p| p[:features].any? && p[:stack].any? && p[:live_url].present? }
  end

  test "leaves unset links as nil so the page can hide them" do
    get root_path

    metr, recoverybot = inertia.props[:projects]
    assert_nil metr[:code_url]
    assert_equal "https://github.com/thisguycolton/HMBLBOT-RecoveryBot", recoverybot[:code_url]
    assert_nil inertia.props.dig(:person, :linkedin_url)
  end

  test "shows the video placeholder until a url is set" do
    get root_path

    assert_nil inertia.props.dig(:video, :media)
  end

  test "renders link preview tags with absolute URLs from SITE_URL" do
    get root_path

    site_url = Rails.configuration.x.site_url
    assert_select "title", @content["meta"]["title"]
    assert_select "meta[name=description][content]"
    assert_select "link[rel=canonical][href=?]", "#{site_url}/"
    assert_select "meta[property='og:title'][content=?]", @content["meta"]["title"]
    assert_select "meta[property='og:url'][content=?]", "#{site_url}/"
    assert_select "meta[property='og:image'][content=?]", "#{site_url}#{@content['meta']['og_image']}"
    assert_select "meta[name='twitter:card'][content=summary_large_image]"
  end

  test "sets no cookies" do
    get root_path

    assert_nil response.headers["Set-Cookie"]
  end

  test "health check responds" do
    get rails_health_check_path

    assert_response :success
  end

  test "every file the content refers to exists in public/" do
    paths = [ @content["meta"]["og_image"], @content["person"]["resume_path"] ] +
            @content["projects"].map { |p| p["screenshot"] }

    paths.each { |path| assert Rails.public_path.join(path.delete_prefix("/")).file?, "missing public#{path}" }
  end
end
