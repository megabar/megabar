module MegaBar
  class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception
    helper_method :sort_column, :sort_direction, :is_displayable
    before_action -> { 
      @mega_class = env[:mega_env][:klass].constantize
      env[:mega_env].keys.each { | env_var | instance_variable_set('@' + env_var.to_s, env[:mega_env][env_var]) }
    }
    before_action->{ 
        #  byebug
     }, only: :edit
    before_action -> { @options = {}; self.try(:get_options) },  only: [:index, :show, :edit, :new]
    # before_action -> { mega_controller },  only: [:index, :show, :edit, :new]
    before_action -> { mega_displays },  only: [:index, :show, :edit, :new] #not save or update..
    before_filter :mega_template
    
    def mega_template
      @index_view_template ||= "mega_bar.html.erb"
      @show_view_template ||= "mega_bar.html.erb"
      @edit_view_template ||= "mega_bar.html.erb"
      @new_view_template ||= "mega_bar.html.erb"
    end

    def _params
      permits = []  
      MegaBar::Field.by_model(env[:mega_env][:model_id]).pluck(:field).each do |att|
        permits << att unless ['id', 'created_at', 'updated_at'].include?(att)
      end
      params.require(controller_name.singularize).permit(permits)
    end
  end
end
