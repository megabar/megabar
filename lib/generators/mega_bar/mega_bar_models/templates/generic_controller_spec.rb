<% the_module_array.each do | m | %>module <%=m %><% end %>
  puts "Did you remember to copy the migration for <%=the_model_file_name%> over to the megabar db/migrate directory?"
  require_relative 'common'
  require 'spec_helper'

  Rails.application.routes.draw do
    resources :<%= the_route_path %>
  end

  RSpec.describe <% the_module_array.each do | m | %><%=m%>::<% end %><% if the_module_array.length %>::<% end %><%= the_controller_name %>, :type => :controller do
    include_context "common" #pretty important!
    let(:a_record) {
      create(:<%=the_model_file_name%>) unless model_class.first
      model_class.first
    }
    let(:controller_class) { <% if the_module_name %><%=the_module_name%>::<% end %><%= the_controller_name %> }
    let(:model_class) { <% if the_module_name %><%=the_module_name%>::<% end %><%= classname %> }
    #variables:
    # 1 the_model_file_path: <%= the_model_file_path %>
    # 2 the_model_file_name: <%= the_model_file_name %>
    # 3 the_controller_file_name: <%= the_controller_file_name %>
    # 4 the_controller_file_path: <%= the_controller_file_path %>
    # 5 the_controller_spec_file_path: <%= the_controller_spec_file_path %>
    # 6 the_controller_spec_file_name: <%= the_controller_spec_file_name %>
    # 7 the_factory_file_path: <%= the_factory_file_path %>
    # 10 the_controller_name: <%= the_controller_name %>
    # 11 the_table_name: <%= the_table_name %>
    # 12 the_module_name: <%= the_module_name %>
    # 13 the_route_name: <%= the_route_name %>
    # 13 the_route_path: <%= the_route_path %>


    let(:controlller) { '<%=the_route_name %>' }
    # let(:invalid_attributes) { { 'tbd' => '' }  }
    # let(:invalid_new) { {tbd: ''} }
    let(:model_and_page) { create(:model_with_page, classname: '<%=classname %>', tablename: '<%=the_table_name %>', name: '<%=classname %>', modyule: '<%= the_module_name %>' ) }
    let(:page_terms) { <%= the_module_array << the_route_path %>  }
    let(:page_name) { '<%= the_module_name %> page'   }
    let(:skip_invalids) { true }
    let(:spec_subject) { '<%= the_model_file_name %>' }
    let(:updated_attrs) { { 'tbd' => 'tbd' } }
    let(:uri) { '<%=the_route_path%>' }
    let(:valid_attributes) {{ 'tbd' => "tbd" } }
    let(:valid_new) { { tbd: 'tbd'} }
    let(:valid_session) { {} }

    let(:fields_and_displays) {
      create(:field_with_displays, field: 'tbd', tablename: '<%=the_table_name%>')
    }
    let(:invalid_attributes) {
      f = build(:<%=the_model_file_name%>)
      { tbd: f[:tbd] }
    }
  end
<% the_module_array.each do | m | %>end<% end %>
