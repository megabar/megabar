FactoryGirl.define do
  factory :<%= the_model_file_name %>, class: <% if the_module_name %><%=the_module_name%>::<% end %><%= the_model_name %> do
    id 1
  end
end