module MegaBar
  class PagesController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern

    def index
      @mega_instance ||= Page.where("mega_page = 'f' or mega_page is null or path = '/'").order(column_sorting)
      super
    end
    def all
      @mega_instance = Page.where(mega_page: 'mega').order(column_sorting)
# .page(@page_number).per(10)
      index
    end
    def edit
      session[:return_to] = request.referer
      super
    end
  end
end
