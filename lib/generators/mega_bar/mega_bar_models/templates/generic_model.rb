<% the_module_name.split('::').each do | m | %>
module <%=m %> 
<% end %>
  class <%= classname %> < ActiveRecord::Base
  end

<% the_module_name.split('::').each do | m | %>
end 
<% end %>