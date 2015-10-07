module MegaBar
  require 'spec_helper'
  require_relative 'common'

  RSpec.describe MegaBar::ModelsController, :type => :controller do
    include_context "common" #pretty important!

    let(:valid_session) { {} }
    let(:uri) { '/mega-bar/models' }
    let(:controlller) { 'mega_bar/models' }
    let(:page_terms) { ['mega-bar', 'models'] }
    let(:page_name) { 'Models Page' }
    let(:valid_new_model) { {schema: 'sqlite', name: 'zoiks', default_sort_field: 'id', classname: 'oink', modyule: '', make_page: ''} }
    let(:invalid_new_model) { {make_page: ''} }
    let(:valid_attributes) {
      m = build(:model)
      { classname: m[:classname], name: m[:name], default_sort_field: m[:default_sort_field], modyule: m[:modyule], id: m[:id]  }
    }
    let(:invalid_attributes) {
      m = build(:model)
      { classname: nil, name: m[:name], default_sort_field: '', id: m[:id]  }
    }
    let(:model) { create(:model_with_page) }
    let(:fields) { #have to at least have the required model fields.
      create(:field_with_displays)
      create(:field_with_displays, field: 'tablename' )
      create(:field_with_displays, field: 'default_sort_field')
      create(:field_with_displays, field: 'name')
    }

    context 'with mega_env' do
      before(:each) do
        MegaBar::Field.skip_callback("create",:after,:make_migration)
        MegaBar::Model.skip_callback("create",:after,:make_all_files)
        MegaBar::Model.set_callback("create", :after, :make_page_for_model)
        MegaBar::Page.set_callback("create", :after, :create_layout_for_page)
        MegaBar::Layout.set_callback("create", :after, :create_block_for_layout)
        MegaBar::Layout.set_callback("create", :after, :create_block_for_layout)
        MegaBar::Block.set_callback("create", :after, :make_model_displays)
        model
        fields
        model_display_format
        model_display_format_2
      end
      after(:each) do
        MegaBar::Field.set_callback("create",:after,:make_migration)
        MegaBar::Model.set_callback("create",:after,:make_all_files)
        MegaBar::Model.destroy_all
        MegaBar::Page.destroy_all
        MegaBar::ModelDisplayFormat.destroy_all
      end

      context 'with callbacks disabled ' do
        before(:each) do
          MegaBar::Field.skip_callback("save",:after,:make_field_displays)
          MegaBar::Field.skip_callback("create",:after,:make_field_displays)
          MegaBar::Model.skip_callback("create",:after,:make_page_for_model)
        end
        after(:each) do
          MegaBar::Field.set_callback("save",:after,:make_field_displays)
          MegaBar::Field.set_callback("create",:after,:make_field_displays)
          MegaBar::Model.set_callback("create",:after,:make_page_for_model)

        end

        describe "GET index"  do
          it "assigns all models as @mega_instance" do
            status, headers, body = MegaBar::ModelsController.action(:index).call(get_env(env_index))
            @controller = body.request.env['action_controller.instance']
            expect(assigns(:mega_instance)).to eq([model])
          end
        end

        describe "GET show" do
          it "assigns the requested model as @mega_instance" do
            status, headers, body = MegaBar::ModelsController.action(:show).call(get_env(env_show))
            @controller = body.request.env['action_controller.instance']
            expect(assigns(:mega_instance)).to eq([model])
          end
        end
        describe "GET new" do
          it "assigns a new model as @mega_instance" do
            status, headers, body = MegaBar::ModelsController.action(:new).call(get_env(env_new))
            @controller = body.request.env['action_controller.instance']
            expect(assigns(:mega_instance)).to be_a_new(Model)
          end
        end

        describe "GET edit" do
          it "assigns the requested model as @mega_instance" do
            status, headers, body = MegaBar::ModelsController.action(:edit).call(get_env(env_edit))
            @controller = body.request.env['action_controller.instance']
            expect(assigns(:mega_instance)).to eq(model)
          end
        end

        describe "POST create" do
          describe "with valid params" do
            it "creates a new Model" do # , focus: true  do
            expect {
              status, headers, body = MegaBar::ModelsController.action(:create).call(get_env(env_create))
              @controller = body.request.env['action_controller.instance']
            }.to change(Model, :count).by(1)
            end

            it "assigns a newly created model as @mega_instance" do
              status, headers, body = MegaBar::ModelsController.action(:create).call(get_env(env_create))
              @controller = body.request.env['action_controller.instance']
              expect(assigns(:mega_instance)).to be_a(Model)
              expect(assigns(:mega_instance)).to be_persisted
            end

            it "redirects to the created model" do # , focus: true do
              status, headers, body = MegaBar::ModelsController.action(:create).call(get_env(env_create))
              @controller = body.request.env['action_controller.instance']
              expect(status).to be(302)
              expect(body.instance_variable_get(:@body).instance_variable_get(:@header)["Location"]).to include(uri) #almost good enough
            end
          end

          describe "with invalid params" do
            it "assigns a newly created but unsaved model as @mega_instance", focus: true do
              status, headers, body = MegaBar::ModelsController.action(:create).call(get_env(env_invalid_create))
              @controller = body.request.env['action_controller.instance']
              expect(assigns(:mega_instance)).to be_a_new(Model)
            end
            it "re-renders the 'new' template" do #, focus: true  do
              status, headers, body = MegaBar::ModelsController.action(:create).call(get_env(env_invalid_create))
              @controller = body.request.env['action_controller.instance']
              expect(response).to render_template('mega_bar.html.erb')
            end
          end
        end

        describe "PUT update" do
          describe "with valid params" do
            let(:new_attributes) {
               m = build(:model)
               { classname: 'testing', name: m[:name], default_sort_field: m[:default_sort_field], id: m[:id]  }
            }
            it "updates the requested model" do
              model = Model.last
              status, headers, body = MegaBar::ModelsController.action(:update).call(get_env(env_update))
              model.reload
              expect(model.attributes).to include( { 'classname' => 'testing' } )
            end

            it "assigns the requested model as @mega_instance" do
              model = Model.last
              status, headers, body = MegaBar::ModelsController.action(:update).call(get_env(env_update))
              @controller = body.request.env['action_controller.instance']
              expect(assigns(:mega_instance)).to eq(model)
            end

            it "redirects to the model" do
              model = Model.last
              status, headers, body = MegaBar::ModelsController.action(:update).call(get_env(env_update))
              expect(body.instance_variable_get(:@body).instance_variable_get(:@header)["Location"]).to include(uri) #almost good enough
            #   expect(response).to redirect_to(model)
            end
          end

          describe "with invalid params" do
            let(:new_attributes) {
               m = build(:model)
               { classname: 'testing', name: '', id: m[:id]  }
            }
            it "assigns the model as @mega_instance" do #, focus: true do
              model = Model.last
              status, headers, body = MegaBar::ModelsController.action(:update).call(get_env(env_update))
              @controller = body.request.env['action_controller.instance']
              expect(assigns(:mega_instance)).to eq(model)
            end

            it "re-renders the 'edit' template" do #, focus: true do
              model = Model.last
              status, headers, body = MegaBar::ModelsController.action(:update).call(get_env(env_update))
              @controller = body.request.env['action_controller.instance']
              expect(response).to render_template("mega_bar.html.erb")
            end
          end
        end
        describe "DELETE destroy" do
          it "destroys the requested model" do
            # model = Model.create! valid_attributes
            expect {
              status, headers, body = MegaBar::ModelsController.action(:destroy).call(get_env(env_destroy))
              @controller = body.request.env['action_controller.instance']
            }.to change(Model, :count).by(-1)
          end

          it "redirects to the models list" do
            status, headers, body = MegaBar::ModelsController.action(:destroy).call(get_env(env_destroy))
            expect(body.instance_variable_get(:@body).instance_variable_get(:@header)["Location"]).to include("/mega-bar/" + url_for('models')) #almost good enough

          end
        end
      end
    end
  end
end
