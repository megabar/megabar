
module MegaBar 

  puts "Did you remember to copy the migration over to the megabar db/migrate directory?"
  require 'spec_helper'

  RSpec.describe MegaBar::ModelDisplayFormatsController, :type => :controller do

    let(:valid_attributes) {
      v = build(:model_display_format)
      { id: v[:id] } # add other fields
    }

    let(:invalid_attributes) {
      # all tests using invalid_attributes marked as pending until you define this.
      i = build(:model_display_format)
      { id: i[:id] } #add other required fields as nil
    }
  
    let(:valid_session) { {} }
    context "with a model " do
      before(:each) do
        MegaBar::Model.skip_callback("create",:after,:make_all_files)
        MegaBar::Model.skip_callback("create",:after,:make_model_displays)
        create(:model, classname: 'ModelDisplayFormat', name: 'Modeldisplayformat', tablename: 'mega_bar_model_display_formats')
      end
      after(:each) do
        MegaBar::Model.find(1).destroy
        MegaBar::Model.set_callback("create",:after,:make_all_files)
        MegaBar::Model.set_callback("create",:after,:make_model_displays)
      end
      describe "GET index" do
        it "assigns all mega_bar_model_display_formats as @mega_instance" do
          model_display_format = ModelDisplayFormat.create! valid_attributes
          get :index, {use_route: MegaBar,  model_id: 1}, valid_session
          expect(assigns(:mega_instance)).to eq([model_display_format])
        end
      end

      describe "GET show" do
        it "assigns the requested model_display_format as @mega_instance" do
          model_display_format = ModelDisplayFormat.create! valid_attributes
          get :show, {use_route: MegaBar,  model_id: 1, :id => model_display_format.to_param}, valid_session
          expect(assigns(:mega_instance)).to eq([model_display_format])
        end
      end
      describe "GET new" do
        it "assigns a new model_display_format as @mega_instance" do
          get :new, {use_route: MegaBar,  model_id: 1}, valid_session
          expect(assigns(:mega_instance)).to be_a_new(ModelDisplayFormat)
        end
      end

      describe "GET edit" do
        it "assigns the requested model_display_format as @mega_instance" do
          model_display_format = ModelDisplayFormat.create! valid_attributes
          get :edit, {use_route: MegaBar,  model_id: 1, :id => model_display_format.to_param}, valid_session
          expect(assigns(:mega_instance)).to eq(model_display_format)
        end
      end
    end
    context 'with a model  and fields for model_display_format' do
      before(:each) do
        MegaBar::Field.skip_callback("save",:after,:make_field_displays) 
        MegaBar::Field.skip_callback("create",:after,:make_field_displays)
        MegaBar::Field.skip_callback("create",:after,:make_migration)
        MegaBar::Model.skip_callback("create",:after,:make_all_files)
        MegaBar::Model.skip_callback("create",:after,:make_model_displays)
        create(:model, classname: 'ModelDisplayFormat', name: 'ModelDisplayFormat', tablename: 'mega_bar_model_display_formats')
        create(:field, tablename: 'mega_bar_model_display_formats', field: 'id')
        # add additional (required) fields
      end
      after(:each) do
        MegaBar::Model.find(1).destroy
        MegaBar::Field.destroy_all
        MegaBar::Field.set_callback("save",:after,:make_field_displays) 
        MegaBar::Field.set_callback("create",:after,:make_field_displays)
        MegaBar::Field.set_callback("create",:after,:make_migration)
        MegaBar::Model.set_callback("create",:after,:make_all_files)
        MegaBar::Model.set_callback("create",:after,:make_model_displays)
      end
      describe "POST create" do
        describe "with valid params" do
          it "creates a new model_display_format" do
            expect {
              post :create, {use_route: MegaBar,  model_id: 1, :model_display_format=> valid_attributes}, valid_session
            }.to change(ModelDisplayFormat, :count).by(1)
          end

          it "assigns a newly created model_display_format as @mega_instance" do
            post :create, {use_route: MegaBar,  model_id: 1, :model_display_format => valid_attributes}, valid_session
            expect(assigns(:mega_instance)).to be_a(ModelDisplayFormat)
            expect(assigns(:mega_instance)).to be_persisted
          end

          it "redirects to the created model_display_format"  do
            post :create, {use_route: MegaBar,  model_id: 1, :model_display_format => valid_attributes}, valid_session
            expect(response).to redirect_to(ModelDisplayFormat.last)
          end
        end

        describe "with invalid params" do
          it "assigns a newly created but unsaved model_display_format as @mega_instance" do
            skip('define invalid_attributes above')
            post :create, {use_route: MegaBar,  model_id: 1, :model_display_format => invalid_attributes}, valid_session
            expect(assigns(:mega_instance)).to be_a_new(ModelDisplayFormat)
          end

          it "re-renders the 'new' template"  do
            skip('define invalid_attributes above')
            post :create, {use_route: MegaBar,  model_id: 1, :model_display_format => invalid_attributes}, valid_session
            expect(response).to render_template('mega_bar.html.erb')
          end
        end
      end

      describe "PUT update" do
        describe "with valid params" do
          let(:new_attributes) { # marked as pending until params added here.
            md = build(:model_display_format)
            { }
          }

          it "updates the requested model_display_format" do
            skip('define new_attributes')
            model_display_format = ModelDisplayFormat.create! valid_attributes
            put :update, {use_route: MegaBar,  :id => model_display_format.to_param, :model_display_format => new_attributes}, valid_session
            model_display_format.reload
            expect(model_display_format.attributes).to include( { 'id' => "5" } )
          end

          it "assigns the requested model_display_format as @mega_instance" do
            model_display_format = ModelDisplayFormat.create! valid_attributes
            put :update, {use_route: MegaBar,  :id => model_display_format.to_param, :model_display_format => valid_attributes}, valid_session
            expect(assigns(:mega_instance)).to eq(model_display_format)
          end

          it "redirects to the model_display_format" do
            model_display_format = ModelDisplayFormat.create! valid_attributes
            put :update, {use_route: MegaBar,  :id => model_display_format.to_param, :model_display_format => valid_attributes}, valid_session
            expect(response).to redirect_to(model_display_format)
          end
        end

        describe "with invalid params" do
          it "assigns the model_display_format as @mega_instance" do
            skip('define invalid_attributes above')
            model_display_format = ModelDisplayFormat.create! valid_attributes
            put :update, {use_route: MegaBar,  :id => model_display_format.to_param, :model_display_format => invalid_attributes}, valid_session
            expect(assigns(:mega_instance)).to eq(model_display_format)
          end

          it "re-renders the 'edit' template" do
            skip('define invalid_attributes above')
            model_display_format = ModelDisplayFormat.create! valid_attributes
            put :update, {use_route: MegaBar,  :id => model_display_format.to_param, :model_display_format => invalid_attributes}, valid_session
            expect(response).to render_template("mega_bar.html.erb")
          end
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested model_display_format" do
        model_display_format = ModelDisplayFormat.create! valid_attributes
        expect {
          delete :destroy, {use_route: MegaBar,  :id => model_display_format.to_param}, valid_session
        }.to change(ModelDisplayFormat, :count).by(-1)
      end

      it "redirects to the model_display_format list" do
        model_display_format = ModelDisplayFormat.create! valid_attributes
        delete :destroy, {use_route: MegaBar,  :id => model_display_format.to_param}, valid_session
        expect(response).to redirect_to("/mega-bar/model-display-formats")
      end
    end

  end  

end 
