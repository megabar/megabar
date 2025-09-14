module MegaBar
  class ApplicationController < ActionController::Base
    
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception
    helper_method :sort_column, :sort_direction, :is_displayable, :might_paginate?, :might_filter?
    
    # Include MegaBar authorization helpers (works with or without CCCUX)
    helper MegaBar::AuthorizationHelper
    
    # Make authorization methods available to controllers
    include MegaBar::AuthorizationHelper
    
    # Include CCCUX functionality if available
    include Cccux::ApplicationControllerConcern if defined?(Cccux::ApplicationControllerConcern)
    
    # Remove old authorization and replace with CCCUX
    # before_action :check_authorization
    before_action :set_vars_for_all
    before_action :set_vars_for_displays # , except: [:update, :create, :destroy]

    def _params
      permits = []
      # Don't permit controller/action - these are routing parameters, not model attributes
      permits << 'page'
      permits << 'sort'
      permits << 'direction'
      permits << 'id'  # Always permit id parameter
      
      # Only query fields if we have a valid model ID
      if env[:mega_env] && env[:mega_env][:modle_id]
        MegaBar::Field.by_model(env[:mega_env][:modle_id]).order('data_type desc').each do |att|
          case att.data_type
          when 'array'
            permits << { att.field => [] }
          else
            permits << att.field unless ['id', 'created_at', 'updated_at', :id].include?(att)
            permits << att.field + '___filter'
          end
        end
      end

      if params[controller_name.singularize]
        @p_params = params.require(controller_name.singularize).permit(permits)
      else
        @p_params = params.permit(permits)
      end
    end

    def env
     request.env
    end

     end
end
