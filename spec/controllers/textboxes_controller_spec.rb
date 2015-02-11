module MegaBar
  require 'spec_helper'

  RSpec.describe MegaBar::TextboxesController, :type => :controller do

    let(:valid_attributes) {
      f = build(:textbox)
      {  field_display_id: f[:field_display_id], size: f[:size], id: f[:id]  }
    }

    let(:invalid_attributes) {
      f = build(:textbox)
      {  field_display_id: nil, size: f[:size], id: f[:id]  }
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
          create(:model, classname: 'textbox', name: 'Textboxes', tablename: 'textboxes')
        end
        after(:each) do
          Model.find(1).destroy
        end
        describe "GET index", focus: true do
          it "assigns all textboxs as @mega_instance" do
            textbox = Textbox.create! valid_attributes
            get :index, {use_route: :mega_bar, model_id: 1}, valid_session
            expect(assigns(:mega_instance)).to eq([textbox])
          end
        end

        describe "GET show" do
          it "assigns the requested textbox as @mega_instance" do
            textbox = Textbox.create! valid_attributes
            get :show, {use_route: :mega_bar, model_id: 1, :id => textbox.to_param}, valid_session
            expect(assigns(:mega_instance)).to eq([textbox])
          end
        end
        describe "GET new" do
          it "assigns a new textbox as @mega_instance" do
            get :new, {use_route: :mega_bar, model_id: 1}, valid_session
            expect(assigns(:mega_instance)).to be_a_new(Textbox)
          end
        end

        describe "GET edit" do
          it "assigns the requested textbox as @mega_instance" do
            textbox = Textbox.create! valid_attributes
            get :edit, {use_route: :mega_bar, model_id: 1, :id => textbox.to_param}, valid_session
            expect(assigns(:mega_instance)).to eq(textbox)
          end
        end
      end
      context 'with a model, a record format and fields for textboxs' do
        before(:each) do
          create(:model, classname: 'textbox', name: 'Textboxes', tablename: 'textboxes')
          create(:field, tablename: 'textbox', field: 'field_display_id')
          create(:field, tablename: 'textbox', field: 'size')
        end
        after(:each) do
          Model.find(1).destroy
          Field.destroy_all      
        end
        describe "POST create" do
          describe "with valid params" do
            it "creates a new Textbox", focus: true do
              #  create(:field_for_field_model)
              expect {
                post :create, {use_route: :mega_bar, model_id: 1, :textbox=> valid_attributes}, valid_session
              }.to change(Textbox, :count).by(1)
            end

            it "assigns a newly created Textbox as @mega_instance" do
              post :create, {use_route: :mega_bar, model_id: 1, :textbox => valid_attributes}, valid_session
              expect(assigns(:mega_instance)).to be_a(Textbox)
              expect(assigns(:mega_instance)).to be_persisted
            end

            it "redirects to the created Textbox"  do
              post :create, {use_route: :mega_bar, model_id: 1, :textbox => valid_attributes}, valid_session
              expect(response).to redirect_to(Textbox.last)
            end
          end

          describe "with invalid params" do
            it "assigns a newly created but unsaved Textbox as @mega_instance", focus: true do
              post :create, {use_route: :mega_bar, model_id: 1, :textbox => invalid_attributes}, valid_session
              expect(assigns(:mega_instance)).to be_a_new(Textbox)
            end

            it "re-renders the 'new' template"  do
              post :create, {use_route: :mega_bar, model_id: 1, :textbox => invalid_attributes}, valid_session
              expect(response).to render_template('mega_bar.html.erb')
            end
          end
        end

        describe "PUT update" do
          describe "with valid params" do
            let(:new_attributes) {
              md = build(:textbox)
              { field_display_id: 5, size: 2  }
            }

            it "updates the requested textbox" do
              textbox = Textbox.create! valid_attributes
              put :update, {use_route: :mega_bar, :id => textbox.to_param, :textbox => new_attributes}, valid_session
              textbox.reload
              expect(textbox.attributes).to include( { 'field_display_id' => 5, 'size' => 2} )
            end

            it "assigns the requested textbox as @mega_instance" do
              textbox = Textbox.create! valid_attributes
              put :update, {use_route: :mega_bar, :id => textbox.to_param, :textbox => valid_attributes}, valid_session
              expect(assigns(:mega_instance)).to eq(textbox)
            end

            it "redirects to the textbox" do
              textbox = Textbox.create! valid_attributes
              put :update, {use_route: :mega_bar, :id => textbox.to_param, :textbox => valid_attributes}, valid_session
              expect(response).to redirect_to(textbox)
            end
          end

          describe "with invalid params" do
            it "assigns the textbox as @mega_instance" do
              textbox = Textbox.create! valid_attributes
              put :update, {use_route: :mega_bar, :id => textbox.to_param, :textbox => invalid_attributes}, valid_session
              expect(assigns(:mega_instance)).to eq(textbox)
            end

            it "re-renders the 'edit' template" do
              textbox = Textbox.create! valid_attributes
              put :update, {use_route: :mega_bar, :id => textbox.to_param, :textbox => invalid_attributes}, valid_session
              expect(response).to render_template("mega_bar.html.erb")
            end
          end
        end
      end

      describe "DELETE destroy" do
        it "destroys the requested textbox" do
          textbox = Textbox.create! valid_attributes
          expect {
            delete :destroy, {use_route: :mega_bar, :id => textbox.to_param}, valid_session
          }.to change(Textbox, :count).by(-1)
        end

        it "redirects to the textbox list" do
          textbox = Textbox.create! valid_attributes
          delete :destroy, {use_route: :mega_bar, :id => textbox.to_param}, valid_session
          expect(response).to redirect_to("/mega-bar/textboxes")
        end
      end
    end
  end
end