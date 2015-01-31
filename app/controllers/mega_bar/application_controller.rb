module MegaBar
  class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception
    helper_method :sort_column, :sort_direction, :is_displayable
    before_action -> { @the_class = constant_from_controller(params[:controller]).constantize }
    before_action ->{ myinit params[:model_id]},  only: [:index, :show, :edit, :new] #not save or update..

    before_filter :mega_template
   
    def mega_template
      @index_view_template ||= "mega_bar.html.erb"
      @show_view_template ||= "mega_bar.html.erb"
      @edit_view_template ||= "mega_bar.html.erb"
      @new_view_template ||= "mega_bar.html.erb"
    end

    def _params
        permits = []
        # tmp = params[:controller].include?('mega_bar') ? 'MegaBar::' + params[:controller][9..-1].classify : params[:controller].classify
        # the_class = tmp.constantize # old way, but doesnt seem needed here.
        # the_class = constant_from_controller(params[:controller]) # new way
      
        MegaBar::Field.by_model(params[:model_id]).pluck(:field).each do |att|
          permits << att unless ['id', 'created_at', 'updated_at'].include?(att)
        end
        params.require(controller_name.singularize).permit(permits)
      end

  end
end