module MegaBar
  require 'spec_helper'
  # This spec was generated by rspec-rails when you ran the scaffold generator.
  # It demonstrates how one might use RSpec to specify the controller code that
  # was generated by Rails when you ran the scaffold generator.
  #
  # It assumes that the implementation code is generated by the rails scaffold
  # generator.  If you are using any extension libraries to generate different
  # controller code, this generated spec may or may not pass.
  #
  # It only uses APIs available in rails and/or rspec-rails.  There are a number
  # of tools you can use to make these specs even more expressive, but we're
  # sticking to rails and rspec-rails APIs to keep things simple and stable.
  #
  # Compared to earlier versions of this generator, there is very limited use of
  # stubs and message expectations in this spec.  Stubs are only used when there
  # is no simpler way to get a handle on the object needed for the example.
  # Message expectations are only used when there is no simpler way to specify
  # that an instance is receiving a specific message.

  RSpec.describe MegaBar::ModelDisplaysController, :type => :controller do

    # This should return the minimal set of attributes required to create a valid
    # Model. As you add validations to Model, be sure to
    # adjust the attributes here as well.
    Field.skip_callback("create",:after,:make_migration)
    Model.skip_callback("create",:after,:make_all_files)
   
    let(:valid_attributes) {
      f = build(:model_display)
      { header: f[:header], action: f[:action], model_id: f[:model_id], format: f[:format], id: f[:id]  }
    }

    let(:invalid_attributes) {
      f = build(:model_display)
      { header: f[:header], action: nil, model_id: nil, format: nil, id: f[:id]  }
    }
    
    # This should return the minimal set of values that should be in the session
    # in order to pass any filters (e.g. authentication) defined in
    # ModelsController. Be sure to keep this updated too.
    let(:valid_session) { {} }
    context "with a model and records_format" do
      before(:each) do
        create(:model, classname: 'fields', name: 'Fields', tablename: 'fields')
        create(:records_format)
      end
      after(:each) do
        Model.find(1).destroy
        RecordsFormat.find(1).destroy
      end

      describe "GET index" do
        it "assigns all model_displays as @mega_instance" do
          model_display = ModelDisplay.create! valid_attributes
          get :index, {use_route: :mega_bar, model_id: 1}, valid_session
          expect(assigns(:mega_instance)).to eq([model_display])
        end
      end

      describe "GET show" do
        it "assigns the requested model_display as @mega_instance" do
          model_display = ModelDisplay.create! valid_attributes
          get :show, {use_route: :mega_bar, model_id: 1, :id => model_display.to_param}, valid_session
          expect(assigns(:mega_instance)).to eq([model_display])
        end
      end
      describe "GET new" do
        it "assigns a new model_display as @mega_instance" do
          get :new, {use_route: :mega_bar, model_id: 1}, valid_session
          expect(assigns(:mega_instance)).to be_a_new(ModelDisplay)
        end
      end

      describe "GET edit" do
        it "assigns the requested model_display as @mega_instance" do
          model_display = ModelDisplay.create! valid_attributes
          get :edit, {use_route: :mega_bar, model_id: 1, :id => model_display.to_param}, valid_session
          expect(assigns(:mega_instance)).to eq(model_display)
        end
      end
    end
    context 'with a model, a record format and fields for model_displays' do
      before(:each) do
        create(:model, classname: 'Fields', tablename: 'fields', name: 'Fields')
        create(:records_format)
        create(:field, tablename: 'model_display', field: 'model_id')
        create(:field, tablename: 'model_display', field: 'action')
        create(:field, tablename: 'model_display', field: 'format')
      end
      after(:each) do
        Model.find(1).destroy
        RecordsFormat.find(1).destroy
        Field.destroy_all
      end
      describe "POST create" do
        describe "with valid params" do
          it "creates a new ModelDisplay" do
            #  create(:field_for_field_model)
            expect {
              post :create, {use_route: :mega_bar, model_id: 1, :model_display=> valid_attributes}, valid_session
            }.to change(ModelDisplay, :count).by(1)
          end

          it "assigns a newly created ModelDisplay as @mega_instance" do
            post :create, {use_route: :mega_bar, model_id: 1, :model_display => valid_attributes}, valid_session
            expect(assigns(:mega_instance)).to be_a(ModelDisplay)
            expect(assigns(:mega_instance)).to be_persisted
          end

          it "redirects to the created ModelDisplay"  do
            post :create, {use_route: :mega_bar, model_id: 1, :model_display => valid_attributes}, valid_session
            expect(response).to redirect_to(ModelDisplay.last)
          end
        end

        describe "with invalid params" do
          it "assigns a newly created but unsaved ModelDisplay as @mega_instance" do
            post :create, {use_route: :mega_bar, model_id: 1, :model_display => invalid_attributes}, valid_session
            expect(assigns(:mega_instance)).to be_a_new(ModelDisplay)
          end

          it "re-renders the 'new' template"  do
            post :create, {use_route: :mega_bar, model_id: 1, :model_display => invalid_attributes}, valid_session
            expect(response).to render_template('mega_bar.html.erb')
          end
        end
      end

      describe "PUT update" do
        describe "with valid params" do
          let(:new_attributes) {
            md = build(:model_display)
            { action: 'edit', format: '2'  }
          }

          it "updates the requested model_display" do
            model_display = ModelDisplay.create! valid_attributes
            put :update, {use_route: :mega_bar, :id => model_display.to_param, :model_display => new_attributes}, valid_session
            model_display.reload
            expect(model_display.attributes).to include( { 'format' => '2', 'action' => 'edit'} )
          end

          it "assigns the requested model_display as @mega_instance" do
            model_display = ModelDisplay.create! valid_attributes
            put :update, {use_route: :mega_bar, :id => model_display.to_param, :model_display => valid_attributes}, valid_session
            expect(assigns(:mega_instance)).to eq(model_display)
          end

          it "redirects to the model_display" do
            model_display = ModelDisplay.create! valid_attributes
            put :update, {use_route: :mega_bar, :id => model_display.to_param, :model_display => valid_attributes}, valid_session
            expect(response).to redirect_to(model_display)
          end
        end

        describe "with invalid params" do
          it "assigns the model_display as @mega_instance" do
            model_display = ModelDisplay.create! valid_attributes
            put :update, {use_route: :mega_bar, :id => model_display.to_param, :model_display => invalid_attributes}, valid_session
            expect(assigns(:mega_instance)).to eq(model_display)
          end

          it "re-renders the 'edit' template" do
            model_display = ModelDisplay.create! valid_attributes
            put :update, {use_route: :mega_bar, :id => model_display.to_param, :model_display => invalid_attributes}, valid_session
            expect(response).to render_template("mega_bar.html.erb")
          end
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested model_display" do
        model_display = ModelDisplay.create! valid_attributes
        expect {
          delete :destroy, {use_route: :mega_bar, :id => model_display.to_param}, valid_session
        }.to change(ModelDisplay, :count).by(-1)
      end

      it "redirects to the model_display list" do
        model_display = ModelDisplay.create! valid_attributes
        delete :destroy, {use_route: :mega_bar, :id => model_display.to_param}, valid_session
        expect(response).to redirect_to("/mega-bar/" + url_for('model_displays'))
      end
    end

  end
end