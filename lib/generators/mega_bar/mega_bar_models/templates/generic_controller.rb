<% the_module_array.each do | m | %>
module <%=m %> 
<% end %>

class <%= the_controller_name %> < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    load_and_authorize_resource if defined?(Cccux::ApplicationControllerConcern)
end

<% the_module_array.each do | m | %>
end 
<% end %>