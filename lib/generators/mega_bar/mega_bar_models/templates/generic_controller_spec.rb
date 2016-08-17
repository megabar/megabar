<% the_module_array.each do | m | %>module <%=m %><% end %>
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe <% the_module_array.each do | m | %><%=m%>::<% end %><%= the_controller_name %>, :type => :controller do
    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing.. 
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/<%=the_model_file_name%>
    let(:updated_attrs) { { 'tbd' => 'tbd' } }
    let(:valid_attributes) {{ 'tbd' => "tbd" } }
    let(:valid_new) { { tbd: 'tbd'} }
    let(:fields_and_displays) {  create(:field_with_displays, field: 'tbd', tablename: '<%=the_table_name%>', model_display_ids: model_model_display_ids) }
    # Megabar says, If you want to test invalid data, modify these: 
    let(:skip_invalids) { true }
    let(:invalid_new) { {tbd: ''} }
    let(:invalid_attributes) {
      f = build(:<%=the_model_file_name%>)
      { tbd: f[:tbd] }
    }
    let(:controlller) { '<%=the_route_name %>' } #might need editing!

    # the rest of these you shouldn't have to mess with.
    let(:controller_class) { <% if the_module_name %><%=the_module_name%>::<% end %><%= the_controller_name %> }
    let(:model_class) { <% if the_module_name %><%=the_module_name%>::<% end %><%= classname %> }
    
    let(:model_and_page) { create(:model_with_page, classname: '<%=classname %>', tablename: '<%=the_table_name %>', name: '<%=classname %>', modyule: '<%= the_module_name %>' ) }
    let(:page_terms) { <%= the_module_array << the_route_path %>  }
    let(:page_name) { '<%= the_module_name %> page'   }
    let(:spec_subject) { '<%= the_model_file_name %>' }
    let(:uri) { '<%=the_route_path%>' }
    let(:valid_session) { {} }
    let(:a_record) {
      create(:<%=the_model_file_name%>) unless model_class.first
      model_class.first
    }

  end
<% the_module_array.each do | m | %>end<% end %>
