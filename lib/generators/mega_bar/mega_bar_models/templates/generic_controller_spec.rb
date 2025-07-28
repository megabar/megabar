<% the_module_array.each do | m | %>module <%=m %><% end %>
  require 'spec_helper'
  
  RSpec.describe <% the_module_array.each do | m | %><%=m%>::<% end %><%= the_controller_name %>, :type => :controller do
    
    describe "<%=classname %> Controller Specifics" do
      it "supports custom functionality" do
        expect(described_class).to be_a(Class)
        expect(described_class.included_modules).to include(MegaBar::MegaBarConcern)
      end
      
      it "inherits from MegaBar::ApplicationController" do
        expect(described_class.superclass).to eq(MegaBar::ApplicationController)
      end
      
      it "responds to standard CRUD actions" do
        expect(described_class.instance_methods).to include(:index, :show, :new, :create, :edit, :update, :destroy)
      end
    end
  end
<% the_module_array.each do | m | %>end<% end %>
