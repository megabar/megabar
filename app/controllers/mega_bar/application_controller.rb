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

    before_action -> { @options = {}; self.try(:get_options) },  only: [:show, :index, :new, :edit]
    before_action -> { 
      env[:mega_env] = add_form_path_to_mega_displays(env[:mega_env])
      @mega_displays = env[:mega_env][:mega_displays]
    }, only: [:show, :index, :new, :edit]
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
