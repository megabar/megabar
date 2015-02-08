<% the_module_array.each do | m | %>
module <%=m %> 
<% end %>

class <%= the_controller_name %> < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern    
end

<% the_module_array.each do | m | %>
end 
<% end %>