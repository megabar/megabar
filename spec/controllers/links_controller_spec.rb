
module MegaBar 

  puts "Did you remember to copy the migration over to the megabar db/migrate directory?"
  require 'spec_helper'
 
  RSpec.describe MegaBar::LinksController, :type => :controller do

    let(:valid_attributes) {
      v = build(:link)
      { id: v[:id] } # add other fields
    }

    let(:invalid_attributes) {
      # all tests using invalid_attributes marked as pending until you define this.
      i = build(:link)
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
          it "assigns all mega_bar_links as @mega_instance" do
            link = Link.create! valid_attributes
            get :index, {use_route: MegaBar,  model_id: 1}, valid_session
            expect(assigns(:mega_instance)).to eq([link])
          end
        end

        describe "GET show" do
          it "assigns the requested link as @mega_instance" do
            link = Link.create! valid_attributes
            get :show, {use_route: MegaBar,  model_id: 1, :id => link.to_param}, valid_session
            expect(assigns(:mega_instance)).to eq([link])
          end
        end
        describe "GET new" do
          it "assigns a new link as @mega_instance" do
            get :new, {use_route: MegaBar,  model_id: 1}, valid_session
            expect(assigns(:mega_instance)).to be_a_new(Link)
          end
        end

        describe "GET edit" do
          it "assigns the requested link as @mega_instance" do
            link = Link.create! valid_attributes
            get :edit, {use_route: MegaBar,  model_id: 1, :id => link.to_param}, valid_session
            expect(assigns(:mega_instance)).to eq(link)
          end
        end
      end
      context 'with a model  and fields for link' do
        before(:each) do
          create(:model, classname: 'Link', name: 'Link', tablename: 'mega_bar_links')
          create(:field, tablename: 'mega_bar_links', field: 'id')
          # add additional (required) fields
        end
        after(:each) do
          MegaBar::Model.find(1).destroy
          MegaBar::Field.destroy_all
        end
        describe "POST create" do
          describe "with valid params" do
            it "creates a new link" do
              expect {
                post :create, {use_route: MegaBar,  model_id: 1, :link=> valid_attributes}, valid_session
              }.to change(Link, :count).by(1)
            end

            it "assigns a newly created link as @mega_instance" do
              post :create, {use_route: MegaBar,  model_id: 1, :link => valid_attributes}, valid_session
              expect(assigns(:mega_instance)).to be_a(Link)
              expect(assigns(:mega_instance)).to be_persisted
            end

            it "redirects to the created link"  do
              post :create, {use_route: MegaBar,  model_id: 1, :link => valid_attributes}, valid_session
              expect(response).to redirect_to(Link.last)
            end
          end

          describe "with invalid params" do
            it "assigns a newly created but unsaved link as @mega_instance" do
              skip('define invalid_attributes above')
              post :create, {use_route: MegaBar,  model_id: 1, :link => invalid_attributes}, valid_session
              expect(assigns(:mega_instance)).to be_a_new(Link)
            end

            it "re-renders the 'new' template"  do
              skip('define invalid_attributes above')
              post :create, {use_route: MegaBar,  model_id: 1, :link => invalid_attributes}, valid_session
              expect(response).to render_template('mega_bar.html.erb')
            end
          end
        end

        describe "PUT update" do
          describe "with valid params" do
            let(:new_attributes) { # marked as pending until params added here.
              md = build(:link)
              { }
            }

            it "updates the requested link" do
              skip('define new_attributes')
              link = Link.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => link.to_param, :link => new_attributes}, valid_session
              link.reload
              expect(link.attributes).to include( { 'id' => "5" } )
            end

            it "assigns the requested link as @mega_instance" do
              link = Link.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => link.to_param, :link => valid_attributes}, valid_session
              expect(assigns(:mega_instance)).to eq(link)
            end

            it "redirects to the link" do
              link = Link.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => link.to_param, :link => valid_attributes}, valid_session
              expect(response).to redirect_to(link)
            end
          end

          describe "with invalid params" do
            it "assigns the link as @mega_instance" do
              skip('define invalid_attributes above')
              link = Link.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => link.to_param, :link => invalid_attributes}, valid_session
              expect(assigns(:mega_instance)).to eq(link)
            end

            it "re-renders the 'edit' template" do
              skip('define invalid_attributes above')
              link = Link.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => link.to_param, :link => invalid_attributes}, valid_session
              expect(response).to render_template("mega_bar.html.erb")
            end
          end
        end
      end

      describe "DELETE destroy" do
        it "destroys the requested link" do
          link = Link.create! valid_attributes
          expect {
            delete :destroy, {use_route: MegaBar,  :id => link.to_param}, valid_session
          }.to change(Link, :count).by(-1)
        end

        it "redirects to the link list" do
          link = Link.create! valid_attributes
          delete :destroy, {use_route: MegaBar,  :id => link.to_param}, valid_session
          expect(response).to redirect_to("/mega-bar/links")
        end
      end
    end
  end  

end 
