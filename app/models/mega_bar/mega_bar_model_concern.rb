module MegaBar
  module MegaBarModelConcern
    module ClassMethods
      def get_path(action = nil)
        binding.pry # is this needed here?
        action ||= env['mega_route'][:action]
        byebug
        case action
        when 'index' 
         url_for(controller: env[:mega_env][:kontroller_class].to_s, action: env['mega_route'][:action], only_path: true)
        when 'new' 
          url_for(controller: env[:mega_env][:kontroller_class].to_s, action: 'create', only_path: true)
        when 'edit' 
          url_for(controller: env[:mega_env][:kontroller_class].to_s, action: 'update', only_path: true)
        else
          form_path = 'ack'
        end
      end
    end
  end
end