<% the_module_array.each do | m | %>module <%=m %> 
<% end %>  class Tmp<%= classname %> < ActiveRecord::Base
  end
<% the_module_array.each do | m | %>end <% end %>
