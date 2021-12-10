module MegaBar
  class PagesController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern

    def index
      @mega_instance ||= Page.where("mega_page = 'f' or mega_page is null or mega_page = '' or mega_page = 'regular' or path = '/'").order(column_sorting)
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

    def get_options
      @options[:mega_bar_pages] =  {
        template_id: Template.all.pluck("name, id"),
        administrator: PermissionLevel.all.pluck("level_name, level"),
      }
    end
  end
end
