<% if the_module_name %>
module <%=the_module_name%>
  <% end %>class <%= classname %> < ActiveRecord::Base
    
<% if the_module_name %>  end<% end %>
end