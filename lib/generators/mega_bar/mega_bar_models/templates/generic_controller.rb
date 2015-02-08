<% the_module_name.split('::').each do | m | %>
module <%=m %> 
<% end %>

class <%= the_controller_name %> < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern    
end

<% the_module_name.split('::').each do | m | %>
end 
<% end %>