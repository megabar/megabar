module MegaBar
  class PagesController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    include MegaBar::AuthorizationConcern
    
    # Override resource loading for custom actions
    def administer_block
      # Load the block instead of the page
      @block = MegaBar::Block.find(params[:id])
      # Check authorization for the block
      if defined?(CanCan::Ability) && respond_to?(:current_user) && current_user
        unless current_user.can?(:administer_block, MegaBar::Page)
          redirect_to root_path, alert: 'Not authorized to administer blocks'
          return
        end
      end
      # Initialize session if needed
      session[:admin_blocks] ||= []
      # Execute the concern logic directly
      block_id = params[:id]
      if session[:admin_blocks].include?(block_id)
        session[:admin_blocks].delete(block_id)
      else
        session[:admin_blocks] << block_id
      end
      redirect_back fallback_location: root_path
    end
    
    def administer_page
      # Load the page for this action
      @page = MegaBar::Page.find(params[:id])
      # Check authorization for the page
      if defined?(CanCan::Ability) && respond_to?(:current_user) && current_user
        unless current_user.can?(:administer_page, MegaBar::Page)
          redirect_to root_path, alert: 'Not authorized to administer pages'
          return
        end
      end
      # Initialize session if needed
      session[:admin_pages] ||= []
      # Execute the concern logic directly
      page_id = params[:id]
      if session[:admin_pages].include?(page_id)
        session[:admin_pages].delete(page_id)
      else
        session[:admin_pages] << page_id
      end
      redirect_back fallback_location: root_path
    end

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
        # administrator: PermissionLevel.all.pluck("level_name, level"),
      }
    end

  end
end
