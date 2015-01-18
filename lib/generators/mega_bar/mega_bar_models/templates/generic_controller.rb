<% if the_module_name %>
module <%=the_module_name%>
  <% end %>class <%= the_controller_name %> < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    private
      def _params
        permits = []
        controller_name.classify.constantize.attribute_names.each do |att|
          permits << att unless ['id', 'created_at', 'updated_at'].include?(att)
        end
        params.require(controller_name.singularize).permit(permits)
      end

<% if the_module_name %>  end<% end %>
end