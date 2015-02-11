module MegaBar
  require 'spec_helper'


  RSpec.describe MegaBar::TextreadsController, :type => :controller do

    # This should return the minimal set of attributes required to create a valid
    # Model. As you add validations to Model, be sure to
    # adjust the attributes here as well.
  
    let(:valid_attributes) {
      f = build(:textread)
      { field_display_id: f[:field_display_id], truncation: f[:truncation], truncation_format: f[:truncation_format], transformation: f[:transformation], id: f[:id] }
    }

    let(:invalid_attributes) {
      f = build(:textread)
      { field_display_id: nil, truncation: f[:truncation], truncation_format: f[:truncation_format], transformation: f[:transformation], id: f[:id] }
    }
    
    # This should return the minimal set of values that should be in the session
    # in order to pass any filters (e.g. authentication) defined in
    # ModelsController. Be sure to keep this updated too.
    let(:valid_session) { {} }
    context "with a model " do
      before(:each) do
        MegaBar::Model.skip_callback("create",:after,:make_all_files)
        MegaBar::Model.skip_callback("create",:after,:make_model_displays)
        create(:model, classname: 'textread', name: 'Textreads', tablename: 'textreads')
      end
      after(:each) do
        Model.find(1).destroy
        MegaBar::Model.set_callback("create",:after,:make_all_files)
        MegaBar::Model.set_callback("create",:after,:make_model_displays)
      
      end
      describe "GET index", focus: true do
        it "assigns all textreads as @mega_instance" do
          textread = Textread.create! valid_attributes
          get :index, {use_route: :mega_bar, model_id: 1}, valid_session
          expect(assigns(:mega_instance)).to eq([textread])
        end
      end

      describe "GET show" do
        it "assigns the requested textread as @mega_instance" do
          textread = Textread.create! valid_attributes
          get :show, {use_route: :mega_bar, model_id: 1, :id => textread.to_param}, valid_session
          expect(assigns(:mega_instance)).to eq([textread])
        end
      end
      describe "GET new" do
        it "assigns a new textread as @mega_instance" do
          get :new, {use_route: :mega_bar, model_id: 1}, valid_session
          expect(assigns(:mega_instance)).to be_a_new(Textread)
        end
      end

      describe "GET edit" do
        it "assigns the requested textread as @mega_instance" do
          textread = Textread.create! valid_attributes
          get :edit, {use_route: :mega_bar, model_id: 1, :id => textread.to_param}, valid_session
          expect(assigns(:mega_instance)).to eq(textread)
        end
      end
    end
    context 'with a model, a record format and fields for textreads' do
      before(:each) do
        MegaBar::Field.skip_callback("save",:after,:make_field_displays) 
        MegaBar::Field.skip_callback("create",:after,:make_field_displays)
        MegaBar::Field.skip_callback("create",:after,:make_migration)
        MegaBar::Model.skip_callback("create",:after,:make_all_files)
        MegaBar::Model.skip_callback("create",:after,:make_model_displays)
        create(:model, classname: 'textread', name: 'Textreads', tablename: 'textreads')
        create(:field, tablename: 'textreads', field: 'field_display_id')
        create(:field, tablename: 'textreads', field: 'truncation')
      end
      after(:each) do
        Model.find(1).destroy
        Field.destroy_all
        MegaBar::Field.set_callback("save",:after,:make_field_displays) 
        MegaBar::Field.set_callback("create",:after,:make_field_displays)
        MegaBar::Field.set_callback("create",:after,:make_migration)
        MegaBar::Model.set_callback("create",:after,:make_all_files)
        MegaBar::Model.set_callback("create",:after,:make_model_displays)
      
      end
      describe "POST create" do
        describe "with valid params" do
          it "creates a new Textread" do
            #  create(:field_for_field_model)
            expect {
              post :create, {use_route: :mega_bar, model_id: 1, :textread=> valid_attributes}, valid_session
            }.to change(Textread, :count).by(1)
          end

          it "assigns a newly created Textread as @mega_instance" do
            post :create, {use_route: :mega_bar, model_id: 1, :textread => valid_attributes}, valid_session
            expect(assigns(:mega_instance)).to be_a(Textread)
            expect(assigns(:mega_instance)).to be_persisted
          end

          it "redirects to the created Textread"  do
            post :create, {use_route: :mega_bar, model_id: 1, :textread => valid_attributes}, valid_session
            expect(response).to redirect_to(Textread.last)
          end
        end

        describe "with invalid params" do
          it "assigns a newly created but unsaved Textread as @mega_instance" do
            post :create, {use_route: :mega_bar, model_id: 1, :textread => invalid_attributes}, valid_session
            expect(assigns(:mega_instance)).to be_a_new(Textread)
          end

          it "re-renders the 'new' template"  do
            post :create, {use_route: :mega_bar, model_id: 1, :textread => invalid_attributes}, valid_session
            expect(response).to render_template('mega_bar.html.erb')
          end
        end
      end

      describe "PUT update" do
        describe "with valid params" do
          let(:new_attributes) {
            md = build(:textread)
            { field_display_id: 5, truncation: 500  }
          }

          it "updates the requested textread" do
            textread = Textread.create! valid_attributes
            put :update, {use_route: :mega_bar, :id => textread.to_param, :textread => new_attributes}, valid_session
            textread.reload
            expect(textread.attributes).to include( { 'field_display_id' => 5, 'truncation' => 500} )
          end

          it "assigns the requested textread as @mega_instance" do
            textread = Textread.create! valid_attributes
            put :update, {use_route: :mega_bar, :id => textread.to_param, :textread => valid_attributes}, valid_session
            expect(assigns(:mega_instance)).to eq(textread)
          end

          it "redirects to the textread" do
            textread = Textread.create! valid_attributes
            put :update, {use_route: :mega_bar, :id => textread.to_param, :textread => valid_attributes}, valid_session
            expect(response).to redirect_to(textread)
          end
        end

        describe "with invalid params" do
          it "assigns the textread as @mega_instance" do
            textread = Textread.create! valid_attributes
            put :update, {use_route: :mega_bar, :id => textread.to_param, :textread => invalid_attributes}, valid_session
            expect(assigns(:mega_instance)).to eq(textread)
          end

          it "re-renders the 'edit' template" do
            textread = Textread.create! valid_attributes
            put :update, {use_route: :mega_bar, :id => textread.to_param, :textread => invalid_attributes}, valid_session
            expect(response).to render_template("mega_bar.html.erb")
          end
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested textread" do
        textread = Textread.create! valid_attributes
        expect {
          delete :destroy, {use_route: :mega_bar, :id => textread.to_param}, valid_session
        }.to change(Textread, :count).by(-1)
      end

      it "redirects to the textread list" do
        textread = Textread.create! valid_attributes
        delete :destroy, {use_route: :mega_bar, :id => textread.to_param}, valid_session
        expect(response).to redirect_to("/mega-bar/textreads")
      end
    end

  end
end