module MegaBar
  class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception
    helper_method :sort_column, :sort_direction, :is_displayable, :might_paginate?, :might_filter?
    before_action :set_vars_for_all
    before_action :set_vars_for_displays # , except: [:update, :create, :destroy]
    skip_before_action :verify_authenticity_token

    def _params
      permits = []
      permits << 'controller'
      permits << 'page'
      permits << 'sort'
      permits << 'direction'
      MegaBar::Field.by_model(env[:mega_env][:modle_id]).order('data_type desc').each do |att|
        case att.data_type
        when 'array'
          permits << { att.field => [] }
        else
          permits << att.field unless ['id', 'created_at', 'updated_at', :id].include?(att)
        end
      end
      @p_params = params.permit(permits)
    end

    def env
     request.env
    end

  end
end
