module MegaBar
  module AuthorizationHelper
    # Base method that handles both prepend and append options
    def link_if_can_with_wrapper(action, subject, text, path, **opts)
      prepend = opts.delete(:prepend)
      append = opts.delete(:append)
      
      if can_perform_action?(action, subject)
        "#{prepend}#{link_to(text, path, **opts)}#{append}".html_safe
      elsif opts.delete(:show_text)
        text
      else
        ""
      end
    end

    # Check if user can perform action - delegates to CCCUX if available, otherwise allows
    def can_perform_action?(action, subject)
      if defined?(Cccux::AuthorizationHelper)
        # CCCUX is available, use its authorization
        can?(action, subject)
      else
        # CCCUX not available, allow all actions
        true
      end
    end

    # Link helpers that match CCCUX interface
    def link_if_can_index(subject, text, path, **opts)
      link_if_can_with_wrapper(:index, subject, text, path, **opts)
    end

    def link_if_can_show(subject, text, path, **opts)
      link_if_can_with_wrapper(:show, subject, text, path, **opts)
    end

    def link_if_can_create(subject, text, path, **opts)
      link_if_can_with_wrapper(:create, subject, text, path, **opts)
    end

    def link_if_can_edit(subject, text, path, **opts)
      link_if_can_with_wrapper(:edit, subject, text, path, **opts)
    end

    def link_if_can_update(subject, text, path, **opts)
      link_if_can_with_wrapper(:update, subject, text, path, **opts)
    end

    def link_if_can_destroy(subject, text, path, **opts)
      link_if_can_with_wrapper(:destroy, subject, text, path, **opts)
    end

    # Generic action helper
    def link_if_can(action, subject, text, path, **opts)
      link_if_can_with_wrapper(action, subject, text, path, **opts)
    end

    # Permission check helpers
    def can_index?(subject)
      can_perform_action?(:index, subject)
    end

    def can_show?(subject)
      can_perform_action?(:show, subject)
    end

    def can_create?(subject)
      can_perform_action?(:create, subject)
    end

    def can_edit?(subject)
      can_perform_action?(:edit, subject)
    end

    def can_update?(subject)
      can_perform_action?(:update, subject)
    end

    def can_destroy?(subject)
      can_perform_action?(:destroy, subject)
    end
  end
end 