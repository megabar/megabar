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

  RSpec.describe module MegaBar::CongasController, :type => :controller do

    # This should return the minimal set of attributes required to create a valid
    # Model. As you add validations to Model, be sure to
    # adjust the attributes here as well.
    MegaBar::Field.skip_callback("create",:after,:make_migration)
    MegaBar::Model.skip_callback("create",:after,:make_all_files)

    #variables:
    # 1 the_model_file_path: app/models/mega_bar/
    # 2 the_model_file_name: conga
    # 3 the_controller_file_name: congas_controller
    # 4 the_controller_file_path: app/controllers/mega_bar/
    # 5 the_controller_spec_file_path: spec/controllers/mega_bar/
    # 6 the_controller_spec_file_name: congas_controller_spec
    # 7 the_factory_file_path: spec/internal/factories/
    # 8 the_file_name: conga
    # 9 the_model_name: Conga
    # 10 the_controller_name: CongasController
    # 11 the_table_name: congas
    # 12 the_module_name: MegaBar
    # 13 the_route_name: congas
    # 13 the_route_path: the_route_name

    let(:valid_attributes) {
      v = build(:conga)
      { id: v[:id] } # add other fields
    }

    let(:invalid_attributes) {
      # all tests using invalid_attributes marked as pending until you define this.
      i = build(:conga)
      { id: i[:id] } #add other required fields as nil
    }
    # This should return the minimal set of values that should be in the session
    # in order to pass any filters (e.g. authentication) defined in
    # ModelsController. Be sure to keep this updated too.
    let(:valid_session) { {} }
    context "with a model " do
      before(:each) do
        create(:model, classname: 'Conga', name: 'Conga', tablename: 'congas')
      end
      after(:each) do
        MegaBar::Model.find(1).destroy
      end
      describe "GET index" do
        it "assigns all congas as @mega_instance" do
          conga = Conga.create! valid_attributes
          get :index, {use_route: :mega_bar,  model_id: 1}, valid_session
          expect(assigns(:mega_instance)).to eq([conga])
        end
      end

      describe "GET show" do
        it "assigns the requested conga as @mega_instance" do
          conga = Conga.create! valid_attributes
          get :show, {use_route: :mega_bar,  model_id: 1, :id => conga.to_param}, valid_session
          expect(assigns(:mega_instance)).to eq([conga])
        end
      end
      describe "GET new" do
        it "assigns a new conga as @mega_instance" do
          get :new, {use_route: :mega_bar,  model_id: 1}, valid_session
          expect(assigns(:mega_instance)).to be_a_new(Conga)
        end
      end

      describe "GET edit" do
        it "assigns the requested conga as @mega_instance" do
          conga = Conga.create! valid_attributes
          get :edit, {use_route: :mega_bar,  model_id: 1, :id => conga.to_param}, valid_session
          expect(assigns(:mega_instance)).to eq(conga)
        end
      end
    end
    context 'with a model  and fields for conga' do
      before(:each) do
        create(:model, classname: 'Conga', name: 'Conga', tablename: 'congas')
        create(:field, tablename: 'congas', field: 'id')
        # add additional (required) fields
      end
      after(:each) do
        MegaBar::Model.find(1).destroy
        MegaBar::Field.destroy_all
      end
      describe "POST create" do
        describe "with valid params" do
          it "creates a new conga" do
            expect {
              post :create, {use_route: :mega_bar,  model_id: 1, :conga=> valid_attributes}, valid_session
            }.to change(Conga, :count).by(1)
          end

          it "assigns a newly created conga as @mega_instance" do
            post :create, {use_route: :mega_bar,  model_id: 1, :conga => valid_attributes}, valid_session
            expect(assigns(:mega_instance)).to be_a(Conga)
            expect(assigns(:mega_instance)).to be_persisted
          end

          it "redirects to the created conga"  do
            post :create, {use_route: :mega_bar,  model_id: 1, :conga => valid_attributes}, valid_session
            expect(response).to redirect_to(Conga.last)
          end
        end

        describe "with invalid params" do
          it "assigns a newly created but unsaved conga as @mega_instance" do
            skip('define invalid_attributes above')
            post :create, {use_route: :mega_bar,  model_id: 1, :conga => invalid_attributes}, valid_session
            expect(assigns(:mega_instance)).to be_a_new(Conga)
          end

          it "re-renders the 'new' template"  do
            skip('define invalid_attributes above')
            post :create, {use_route: :mega_bar,  model_id: 1, :conga => invalid_attributes}, valid_session
            expect(response).to render_template('mega_bar.html.erb')
          end
        end
      end

      describe "PUT update" do
        describe "with valid params" do
          let(:new_attributes) { # marked as pending until params added here.
            md = build(:conga)
            { }
          }

          it "updates the requested conga" do
            skip('define new_attributes')
            conga = Conga.create! valid_attributes
            put :update, {use_route: :mega_bar,  :id => conga.to_param, :conga => new_attributes}, valid_session
            conga.reload
            expect(conga.attributes).to include( { 'id' => "5" } )
          end

          it "assigns the requested conga as @mega_instance" do
            conga = Conga.create! valid_attributes
            put :update, {use_route: :mega_bar,  :id => conga.to_param, :conga => valid_attributes}, valid_session
            expect(assigns(:mega_instance)).to eq(conga)
          end

          it "redirects to the conga" do
            conga = Conga.create! valid_attributes
            put :update, {use_route: :mega_bar,  :id => conga.to_param, :conga => valid_attributes}, valid_session
            expect(response).to redirect_to(conga)
          end
        end

        describe "with invalid params" do
          it "assigns the conga as @mega_instance" do
            skip('define invalid_attributes above')
            conga = Conga.create! valid_attributes
            put :update, {use_route: :mega_bar,  :id => conga.to_param, :conga => invalid_attributes}, valid_session
            expect(assigns(:mega_instance)).to eq(conga)
          end

          it "re-renders the 'edit' template" do
            skip('define invalid_attributes above')
            conga = Conga.create! valid_attributes
            put :update, {use_route: :mega_bar,  :id => conga.to_param, :conga => invalid_attributes}, valid_session
            expect(response).to render_template("mega_bar.html.erb")
          end
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested conga" do
        conga = Conga.create! valid_attributes
        expect {
          delete :destroy, {use_route: :mega_bar,  :id => conga.to_param}, valid_session
        }.to change(Conga, :count).by(-1)
      end

      it "redirects to the conga list" do
        conga = Conga.create! valid_attributes
        delete :destroy, {use_route: :mega_bar,  :id => conga.to_param}, valid_session
        expect(response).to redirect_to("/mega-bar/the_route_name")
      end
    end

  end  
end