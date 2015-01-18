<% if the_module_name %>
module <%=the_module_name%>
  <% end %>class <%= the_controller_name %> < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern    
<% if the_module_name %>  end<% end %>
end