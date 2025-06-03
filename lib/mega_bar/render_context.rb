module MegaBar
  class RenderContext
    attr_reader :page_info, :route_info, :pagination, :site, :env, :user, :request

    def initialize(page_info:, route_info:, pagination:, site:, env:, user:, request: nil)
      @page_info = page_info
      @route_info = route_info
      @pagination = pagination
      @site = site
      @env = env
      @user = user
      @request = request
    end
  end
end 