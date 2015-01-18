module MegaBar
  class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    helper_method :sort_column, :sort_direction, :is_displayable
    before_action :app_init
    before_action ->{ myinit params[:model_id]},  only: [:index, :show, :edit, :new] #not save or update..
    protect_from_forgery with: :exception

    before_filter :index_view_template, only: :index
    before_filter :show_view_template, only: :show
    before_filter :edit_view_template, only: :edit 
    before_filter :new_view_template, only: :new

    
    def index_view_template
      @index_view_template ||= "mega_bar.html.erb"
    end
    def show_view_template
      @show_view_template ||= "mega_bar.html.erb"
    end
    def edit_view_template
      @edit_view_template ||= "mega_bar.html.erb"
    end
    def new_view_template
      @new_view_template ||= "mega_bar.html.erb"
    end

    def _params
        permits = []
        controller_name.classify.constantize.attribute_names.each do |att|
          permits << att unless ['id', 'created_at', 'updated_at'].include?(att)
        end
        params.require(controller_name.singularize).permit(permits)
      end

  end
end