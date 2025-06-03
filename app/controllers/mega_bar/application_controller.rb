module MegaBar
  class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception
    helper_method :sort_column, :sort_direction, :is_displayable, :might_paginate?, :might_filter?
    # before_action :check_authorization  # Temporarily commented out to disable authorization
    before_action :set_vars_for_all
    before_action :set_vars_for_displays # , except: [:update, :create, :destroy]

    skip_before_action :verify_authenticity_token

    def _params
      permits = []
      permits << 'controller'
      permits << 'page'
      permits << 'sort'
      permits << 'direction'
      
      # Add nil safety but keep original modle_id spelling
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

    def current_user
      @current_user || MegaBar::User.find(session[:user_id]) if session[:user_id]
    end

    helper_method :current_user

    def clear_session
      session[:mega_filters] = {}
      session[:admin_blocks] = []
      session[:admin_pages] = []
      session[:return_to] = nil
      redirect_to request.referer || '/mega-bar', notice: 'Session cleared!'
    end
  end
end
