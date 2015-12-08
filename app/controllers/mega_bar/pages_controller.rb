module MegaBar
  class PagesController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern

    def index
      admin_pages = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]
      @mega_instance ||= Page.where(['id not in (?)', admin_pages ]).order(column_sorting)
      super
    end
    def all
      @mega_instance = Page.all.order(column_sorting)
      index
    end
    def edit
      session[:return_to] = request.referer
      super
    end
  end
end
