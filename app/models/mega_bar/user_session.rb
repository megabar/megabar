module MegaBar
  class UserSession
    def initialize(session)
      @session = session
      @session[:admin_blocks] ||= []
      byebug
    end
  end
end