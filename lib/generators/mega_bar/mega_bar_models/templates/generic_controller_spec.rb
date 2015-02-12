<% the_module_array.each do | m | %>
module <%=m %> 
<% end %>
  puts "Did you remember to copy the migration over to the megabar db/migrate directory?"
  require 'spec_helper'
 
  RSpec.describe <% if the_module_name %><%=the_module_name%>::<% end %><%= the_controller_name %>, :type => :controller do

    let(:valid_attributes) {
      v = build(:<%= the_model_file_name %>)
      { id: v[:id] } # add other fields
    }

    let(:invalid_attributes) {
      # all tests using invalid_attributes marked as pending until you define this.
      i = build(:<%= the_model_file_name %>)
      { id: i[:id] } #add other required fields as nil
    }

    let(:valid_session) { {} }


    context 'with callbacks disabled' do 
      before(:each) do
        MegaBar::Field.skip_callback("save",:after,:make_field_displays) 
        MegaBar::Field.skip_callback("create",:after,:make_field_displays)
        MegaBar::Field.skip_callback("create",:after,:make_migration)
        MegaBar::Model.skip_callback("create",:after,:make_all_files)
        MegaBar::Model.skip_callback("create",:after,:make_model_displays)
      end
      after(:each) do
        MegaBar::Field.set_callback("save",:after,:make_field_displays) 
        MegaBar::Field.set_callback("create",:after,:make_field_displays)
        MegaBar::Field.set_callback("create",:after,:make_migration)
        MegaBar::Model.set_callback("create",:after,:make_all_files)
        MegaBar::Model.set_callback("create",:after,:make_model_displays)
      end
      context "with a model " do
        before(:each) do
          create(:model)
        end
        after(:each) do
          MegaBar::Model.find(1).destroy
        end
        describe "GET index" do
          it "assigns all <%= the_table_name %> as @mega_instance" do
            <%= the_model_file_name %> = <%= classname %>.create! valid_attributes
            get :index, {<%= use_route %> model_id: 1}, valid_session
            expect(assigns(:mega_instance)).to eq([<%= the_model_file_name %>])
          end
        end

        describe "GET show" do
          it "assigns the requested <%= the_model_file_name %> as @mega_instance" do
            <%= the_model_file_name %> = <%= classname %>.create! valid_attributes
            get :show, {<%= use_route %> model_id: 1, :id => <%= the_model_file_name %>.to_param}, valid_session
            expect(assigns(:mega_instance)).to eq([<%= the_model_file_name %>])
          end
        end
        describe "GET new" do
          it "assigns a new <%= the_model_file_name %> as @mega_instance" do
            get :new, {<%= use_route %> model_id: 1}, valid_session
            expect(assigns(:mega_instance)).to be_a_new(<%= classname %>)
          end
        end

        describe "GET edit" do
          it "assigns the requested <%= the_model_file_name %> as @mega_instance" do
            <%= the_model_file_name %> = <%= classname %>.create! valid_attributes
            get :edit, {<%= use_route %> model_id: 1, :id => <%= the_model_file_name %>.to_param}, valid_session
            expect(assigns(:mega_instance)).to eq(<%= the_model_file_name %>)
          end
        end
      end
      context 'with a model  and fields for <%= the_model_file_name %>' do
        before(:each) do
          create(:model, classname: '<%= classname %>', name: '<%= classname %>', tablename: '<%= the_table_name %>')
          create(:field, tablename: '<%= the_table_name %>', field: 'id')
          # add additional (required) fields
        end
        after(:each) do
          MegaBar::Model.find(1).destroy
          MegaBar::Field.destroy_all
        end
        describe "POST create" do
          describe "with valid params" do
            it "creates a new <%= the_model_file_name %>" do
              expect {
                post :create, {<%= use_route %> model_id: 1, :<%= the_model_file_name %>=> valid_attributes}, valid_session
              }.to change(<%= classname %>, :count).by(1)
            end

            it "assigns a newly created <%= the_model_file_name %> as @mega_instance" do
              post :create, {<%= use_route %> model_id: 1, :<%= the_model_file_name %> => valid_attributes}, valid_session
              expect(assigns(:mega_instance)).to be_a(<%= classname %>)
              expect(assigns(:mega_instance)).to be_persisted
            end

            it "redirects to the created <%= the_model_file_name %>"  do
              post :create, {<%= use_route %> model_id: 1, :<%= the_model_file_name %> => valid_attributes}, valid_session
              expect(response).to redirect_to(<%= classname %>.last)
            end
          end

          describe "with invalid params" do
            it "assigns a newly created but unsaved <%= the_model_file_name %> as @mega_instance" do
              skip('define invalid_attributes above')
              post :create, {<%= use_route %> model_id: 1, :<%= the_model_file_name %> => invalid_attributes}, valid_session
              expect(assigns(:mega_instance)).to be_a_new(<%= classname %>)
            end

            it "re-renders the 'new' template"  do
              skip('define invalid_attributes above')
              post :create, {<%= use_route %> model_id: 1, :<%= the_model_file_name %> => invalid_attributes}, valid_session
              expect(response).to render_template('mega_bar.html.erb')
            end
          end
        end

        describe "PUT update" do
          describe "with valid params" do
            let(:new_attributes) { # marked as pending until params added here.
              md = build(:<%= the_model_file_name %>)
              { }
            }

            it "updates the requested <%= the_model_file_name %>" do
              skip('define new_attributes')
              <%= the_model_file_name %> = <%= classname %>.create! valid_attributes
              put :update, {<%= use_route %> :id => <%= the_model_file_name %>.to_param, :<%= the_model_file_name %> => new_attributes}, valid_session
              <%= the_model_file_name %>.reload
              expect(<%= the_model_file_name %>.attributes).to include( { 'id' => "5" } )
            end

            it "assigns the requested <%= the_model_file_name %> as @mega_instance" do
              <%= the_model_file_name %> = <%= classname %>.create! valid_attributes
              put :update, {<%= use_route %> :id => <%= the_model_file_name %>.to_param, :<%= the_model_file_name %> => valid_attributes}, valid_session
              expect(assigns(:mega_instance)).to eq(<%= the_model_file_name %>)
            end

            it "redirects to the <%= the_model_file_name %>" do
              <%= the_model_file_name %> = <%= classname %>.create! valid_attributes
              put :update, {<%= use_route %> :id => <%= the_model_file_name %>.to_param, :<%= the_model_file_name %> => valid_attributes}, valid_session
              expect(response).to redirect_to(<%= the_model_file_name %>)
            end
          end

          describe "with invalid params" do
            it "assigns the <%= the_model_file_name %> as @mega_instance" do
              skip('define invalid_attributes above')
              <%= the_model_file_name %> = <%= classname %>.create! valid_attributes
              put :update, {<%= use_route %> :id => <%= the_model_file_name %>.to_param, :<%= the_model_file_name %> => invalid_attributes}, valid_session
              expect(assigns(:mega_instance)).to eq(<%= the_model_file_name %>)
            end

            it "re-renders the 'edit' template" do
              skip('define invalid_attributes above')
              <%= the_model_file_name %> = <%= classname %>.create! valid_attributes
              put :update, {<%= use_route %> :id => <%= the_model_file_name %>.to_param, :<%= the_model_file_name %> => invalid_attributes}, valid_session
              expect(response).to render_template("mega_bar.html.erb")
            end
          end
        end
      end

      describe "DELETE destroy" do
        it "destroys the requested <%= the_model_file_name %>" do
          <%= the_model_file_name %> = <%= classname %>.create! valid_attributes
          expect {
            delete :destroy, {<%= use_route %> :id => <%= the_model_file_name %>.to_param}, valid_session
          }.to change(<%= classname %>, :count).by(-1)
        end

        it "redirects to the <%= the_model_file_name %> list" do
          <%= the_model_file_name %> = <%= classname %>.create! valid_attributes
          delete :destroy, {<%= use_route %> :id => <%= the_model_file_name %>.to_param}, valid_session
          expect(response).to redirect_to("/mega-bar/<%= the_route_path %>")
        end
      end
    end
  end  
<% the_module_array.each do | m | %>
end 
<% end %>