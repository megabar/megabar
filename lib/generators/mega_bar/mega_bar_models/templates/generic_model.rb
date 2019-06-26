<% the_module_array.each do | m | %>module <%=m %>
<% end %>  class <%= classname %> < ActiveRecord::Base
  <%= position %>
  end
<% the_module_array.each do | m | %>end <% end %>
