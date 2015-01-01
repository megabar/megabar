<% if the_module_name %>
module <%=the_module_name%>
  <% end %>class <%= the_model_name %> < ActiveRecord::Base
    
<% if the_module_name %>  end<% end %>
end