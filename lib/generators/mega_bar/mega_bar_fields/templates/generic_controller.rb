<% if the_module_name %>
module <%=the_module_name%>
  <% end %>class <%= the_controller_name %> < ApplicationController
    include MegaBarConcern
    
    private
      # Never trust parameters from the scary internet, only allow the white list through.
      def _params
        params.require(:textbox).permit()
      end
<% if the_module_name %>  end<% end %>
end