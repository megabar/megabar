RSpec.shared_context "common", :a => :b do
  let(:controller_instance) { body.request.env['action_controller.instance'] }
  let(:env_create) { {uri: uri, params: params_for_create, page: page_info, rout: rout_for_collection}  }
  let(:env_destroy) { {uri: uri, params: params_for_destroy, page: page_info_for_show, rout: rout_for_member}  }
  let(:env_edit) { {uri: uri, params: params_for_edit, page: page_info_for_show, rout: rout_for_member}  }
  let(:env_index) { {uri: uri, params: params_for_index, page: page_info, rout: rout_for_collection}  }
  let(:env_invalid_create) { {uri: uri, params: params_for_invalid_create, page: page_info, rout: rout_for_collection}  }
  let(:env_new) { {uri: uri, params: params_for_new, page: page_info, rout: rout_for_collection}  }
  let(:env_show) { {uri: uri, params: params_for_show, page: page_info_for_show, rout: rout_for_member}  }
  let(:env_update) { {uri: uri, params: params_for_update, page: page_info_for_show, rout: rout_for_member}  }
  let(:env_invalid_update) { {uri: uri, params: params_for_invalid_update, page: page_info_for_show, rout: rout_for_member}  }
  let(:model_display_format_2) { create(:model_display_format_2) }
  let(:model_display_format) { create(:model_display_format) }
  let(:page_info_for_show) { {page_id: 1, page_path: uri, terms: page_terms, vars: [23], name: page_name} }
  let(:page_info) { {page_id: 1, page_path: uri, terms: page_terms, vars: [], name: page_name} }
  let(:params_for_create) { {id: nil, action: 'create', controller: controlller, spec_subject => valid_new } }
  let(:params_for_destroy) {  {id: '1', action: 'destroy', controller: controlller} }
  let(:params_for_edit) {  {id: '1', action: 'edit', controller: controlller} }
  let(:params_for_index) { {action: 'index', controller: controlller} }
  let(:params_for_invalid_create) { {id: nil, action: 'create', controller: controlller, spec_subject => invalid_new } }
  let(:params_for_invalid_update) { {id: '1', action: 'update', controller: controlller, spec_subject => invalid_attributes} }
  let(:params_for_new) { {action: 'new', controller: controlller} }
  let(:params_for_show) { {action: 'index', controller: controlller, id: '1'} }
  let(:params_for_update) { {id: '1', action: 'update', controller: controlller, spec_subject => valid_attributes} }
  let(:rout_for_collection) { {action: 'index', controller: controlller} }
  let(:rout_for_member) { {action: 'index', controller: controlller, id: 1} }
  let(:rout_for_update) { {controller: controlller, action: 'update', id: 1} }

  context 'with mega_env' do
    before(:each) do
      MegaBar::Field.skip_callback("create",:after,:make_migration)
      MegaBar::Model.skip_callback("create",:after,:make_all_files)
      MegaBar::Model.set_callback("create", :after, :make_page_for_model)
      MegaBar::Page.set_callback("create", :after, :create_layout_for_page)
      MegaBar::Layout.set_callback("create", :after, :create_block_for_layout)
      MegaBar::Layout.set_callback("create", :after, :create_block_for_layout)
      MegaBar::Block.set_callback("create", :after, :make_model_displays)
      model_and_page
      fields_and_displays
      a_record
      model_display_format unless MegaBar::ModelDisplayFormat.first
      model_display_format_2 unless MegaBar::ModelDisplayFormat.count > 1
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
        MegaBar::Layout.skip_callback("create",:after,:create_block_for_layout)
      end
      after(:each) do
        MegaBar::Field.set_callback("save",:after,:make_field_displays)
        MegaBar::Field.set_callback("create",:after,:make_field_displays)
        MegaBar::Model.set_callback("create",:after,:make_page_for_model)
        MegaBar::Layout.set_callback("create",:after,:create_block_for_layout)
      end

      describe "GET index"  do
        it "assigns all records as @mega_instance", focus: true do
          status, headers, body = controller_class.action(:index).call(get_env(env_index))
          @controller = body.request.env['action_controller.instance']
          assigns(:mega_instance).each_with_index do | v, k |
            expect(v).to have_same_attributes_as(model_class.order(id: :desc)[k])
          end
        end
      end

      describe "GET show" do
        it "assigns the requested record as @mega_instance" do
          status, headers, body = controller_class.action(:show).call(get_env(env_show))
          @controller = body.request.env['action_controller.instance']
          expect(assigns(:mega_instance)).to eq([a_record])
        end
      end
      describe "GET new" do
        it "assigns a new record as @mega_instance" do
          status, headers, body = controller_class.action(:new).call(get_env(env_new))
          @controller = body.request.env['action_controller.instance']
          expect(assigns(:mega_instance)).to be_a_new(model_class)
        end
      end

      describe "GET edit" do
        it "assigns the requested record as @mega_instance" do
          status, headers, body = controller_class.action(:edit).call(get_env(env_edit))
          @controller = body.request.env['action_controller.instance']
          expect(assigns(:mega_instance)).to eq(a_record)
        end
      end

      describe "POST create" do
        describe "with valid params" do
          it "creates a new record" do
            expect {
              status, headers, body = controller_class.action(:create).call(get_env(env_create))
              @controller = body.request.env['action_controller.instance']
            }.to change(model_class, :count).by(1)
          end

          it "assigns a newly created record as @mega_instance" do
            status, headers, body = controller_class.action(:create).call(get_env(env_create))
            @controller = body.request.env['action_controller.instance']
            expect(assigns(:mega_instance)).to be_a(model_class)
            expect(assigns(:mega_instance)).to be_persisted
          end

          it "redirects to the created record" do # , focus: true do
            status, headers, body = controller_class.action(:create).call(get_env(env_create))
            @controller = body.request.env['action_controller.instance']
            expect(status).to be(302)
            expect(body.instance_variable_get(:@body).instance_variable_get(:@header)["Location"]).to include(uri) #almost good enough
          end
        end

        describe "with invalid params" do
          it "assigns a newly created but unsaved record as @mega_instance" do
            status, headers, body = controller_class.action(:create).call(get_env(env_invalid_create))
            @controller = body.request.env['action_controller.instance']
            expect(assigns(:mega_instance)).to be_a_new(model_class)
          end
          it "re-renders the 'new' template" do #, focus: true  do
            status, headers, body = controller_class.action(:create).call(get_env(env_invalid_create))
            @controller = body.request.env['action_controller.instance']
            expect(response).to render_template('mega_bar.html.erb')
          end
        end
      end

      describe "PUT update" do
        describe "with valid params" do
          it "updates the requested record" do # , focus: true do
            record = model_class.first
            status, headers, body = controller_class.action(:update).call(get_env(env_update))
            record.reload
            expect(record.attributes).to include( updated_attrs )
          end

          it "assigns the requested record as @mega_instance" do
            model = model_class.last
            status, headers, body = controller_class.action(:update).call(get_env(env_update))
            @controller = body.request.env['action_controller.instance']
            expect(assigns(:mega_instance)).to eq(a_record)
          end

          it "redirects to the record" do
            model = model_class.last
            status, headers, body = controller_class.action(:update).call(get_env(env_update))
            expect(body.instance_variable_get(:@body).instance_variable_get(:@header)["Location"]).to include(uri) #almost good enough
          #   expect(response).to redirect_to(model)
          end
        end

        describe "with invalid params" do
          it "assigns the record as @mega_instance" do #, focus: true do
            model = model_class.last
            status, headers, body = controller_class.action(:update).call(get_env(env_invalid_update))
            @controller = body.request.env['action_controller.instance']
            expect(assigns(:mega_instance)).to eq(a_record)
          end

          it "re-renders the 'edit' template" do # , focus: true do
            model = model_class.last
            status, headers, body = controller_class.action(:update).call(get_env(env_invalid_update))
            @controller = body.request.env['action_controller.instance']
            expect(response).to render_template("mega_bar.html.erb")
          end
        end
      end
      describe "DELETE destroy" do
        it "destroys the requested record" do
          expect {
            status, headers, body = controller_class.action(:destroy).call(get_env(env_destroy))
            @controller = body.request.env['action_controller.instance']
          }.to change(model_class, :count).by(-1)
        end

        it "redirects to the index list" do
          status, headers, body = controller_class.action(:destroy).call(get_env(env_destroy))
          expect(body.instance_variable_get(:@body).instance_variable_get(:@header)["Location"]).to include(uri) #almost good enough
        end
      end
    end
  end
end
