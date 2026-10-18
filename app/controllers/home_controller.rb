class HomeController < ApplicationController
  def index
    content = SiteContent.load
    @meta = content.meta
    render inertia: "Home", props: content.props
  end
end
