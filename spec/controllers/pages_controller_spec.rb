
module MegaBar 

  puts "Did you remember to copy the migration over to the megabar db/migrate directory?"
  require 'spec_helper'
 
  RSpec.describe MegaBar::PagesController, :type => :controller do

    let(:valid_attributes) {
      v = build(:page)
      { id: v[:id] } # add other fields
    }

    let(:invalid_attributes) {
      # all tests using invalid_attributes marked as pending until you define this.
      i = build(:page)
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
          it "assigns all mega_bar_pages as @mega_instance" do
            page = Page.create! valid_attributes
            get :index, {use_route: MegaBar,  model_id: 1}, valid_session
            expect(assigns(:mega_instance)).to eq([page])
          end
        end

        describe "GET show" do
          it "assigns the requested page as @mega_instance" do
            page = Page.create! valid_attributes
            get :show, {use_route: MegaBar,  model_id: 1, :id => page.to_param}, valid_session
            expect(assigns(:mega_instance)).to eq([page])
          end
        end
        describe "GET new" do
          it "assigns a new page as @mega_instance" do
            get :new, {use_route: MegaBar,  model_id: 1}, valid_session
            expect(assigns(:mega_instance)).to be_a_new(Page)
          end
        end

        describe "GET edit" do
          it "assigns the requested page as @mega_instance" do
            page = Page.create! valid_attributes
            get :edit, {use_route: MegaBar,  model_id: 1, :id => page.to_param}, valid_session
            expect(assigns(:mega_instance)).to eq(page)
          end
        end
      end
      context 'with a model  and fields for page' do
        before(:each) do
          create(:model, classname: 'Page', name: 'Page', tablename: 'mega_bar_pages')
          create(:field, tablename: 'mega_bar_pages', field: 'id')
          # add additional (required) fields
        end
        after(:each) do
          MegaBar::Model.find(1).destroy
          MegaBar::Field.destroy_all
        end
        describe "POST create" do
          describe "with valid params" do
            it "creates a new page" do
              expect {
                post :create, {use_route: MegaBar,  model_id: 1, :page=> valid_attributes}, valid_session
              }.to change(Page, :count).by(1)
            end

            it "assigns a newly created page as @mega_instance" do
              post :create, {use_route: MegaBar,  model_id: 1, :page => valid_attributes}, valid_session
              expect(assigns(:mega_instance)).to be_a(Page)
              expect(assigns(:mega_instance)).to be_persisted
            end

            it "redirects to the created page"  do
              post :create, {use_route: MegaBar,  model_id: 1, :page => valid_attributes}, valid_session
              expect(response).to redirect_to(Page.last)
            end
          end

          describe "with invalid params" do
            it "assigns a newly created but unsaved page as @mega_instance" do
              skip('define invalid_attributes above')
              post :create, {use_route: MegaBar,  model_id: 1, :page => invalid_attributes}, valid_session
              expect(assigns(:mega_instance)).to be_a_new(Page)
            end

            it "re-renders the 'new' template"  do
              skip('define invalid_attributes above')
              post :create, {use_route: MegaBar,  model_id: 1, :page => invalid_attributes}, valid_session
              expect(response).to render_template('mega_bar.html.erb')
            end
          end
        end

        describe "PUT update" do
          describe "with valid params" do
            let(:new_attributes) { # marked as pending until params added here.
              md = build(:page)
              { }
            }

            it "updates the requested page" do
              skip('define new_attributes')
              page = Page.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => page.to_param, :page => new_attributes}, valid_session
              page.reload
              expect(page.attributes).to include( { 'id' => "5" } )
            end

            it "assigns the requested page as @mega_instance" do
              page = Page.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => page.to_param, :page => valid_attributes}, valid_session
              expect(assigns(:mega_instance)).to eq(page)
            end

            it "redirects to the page" do
              page = Page.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => page.to_param, :page => valid_attributes}, valid_session
              expect(response).to redirect_to(page)
            end
          end

          describe "with invalid params" do
            it "assigns the page as @mega_instance" do
              skip('define invalid_attributes above')
              page = Page.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => page.to_param, :page => invalid_attributes}, valid_session
              expect(assigns(:mega_instance)).to eq(page)
            end

            it "re-renders the 'edit' template" do
              skip('define invalid_attributes above')
              page = Page.create! valid_attributes
              put :update, {use_route: MegaBar,  :id => page.to_param, :page => invalid_attributes}, valid_session
              expect(response).to render_template("mega_bar.html.erb")
            end
          end
        end
      end

      describe "DELETE destroy" do
        it "destroys the requested page" do
          page = Page.create! valid_attributes
          expect {
            delete :destroy, {use_route: MegaBar,  :id => page.to_param}, valid_session
          }.to change(Page, :count).by(-1)
        end

        it "redirects to the page list" do
          page = Page.create! valid_attributes
          delete :destroy, {use_route: MegaBar,  :id => page.to_param}, valid_session
          expect(response).to redirect_to("/mega-bar/pages")
        end
      end
    end
  end  

end 
