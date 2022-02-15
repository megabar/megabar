module MegaBar
  class UserSession
    def initialize(session)
      @session = session
      @session[:admin_blocks] ||= []
    end
  end
end