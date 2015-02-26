module MegaBar
  class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception
    helper_method :sort_column, :sort_direction, :is_displayable
    before_action :set_vars_for_all
    before_action :set_vars_for_displays, only: [:show, :index, :new, :edit]

    def _params
      permits = []  
      MegaBar::Field.by_model(env[:mega_env][:model_id]).pluck(:field).each do |att|
        permits << att unless ['id', 'created_at', 'updated_at'].include?(att)
      end
      params.require(controller_name.singularize).permit(permits)
    end
  end
end
