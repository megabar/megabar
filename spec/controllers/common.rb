RSpec.shared_context "common", :a => :b do
  let(:model_display_format) { create(:model_display_format) }
  let(:model_display_format_2) { create(:model_display_format_2) }
  let(:page_info) { {page_id: 1, page_path: uri, terms: page_terms, vars: [], name: page_name} }
  let(:page_info_for_show) { {page_id: 1, page_path: uri, terms: page_terms, vars: [23], name: page_name} }
  let(:rout_for_collection) { {action: 'index', controller: controlller} }
  let(:rout_for_member) { {action: 'index', controller: controlller, id: 1} }
  let(:rout_for_update) { {controller: controlller, action: 'update', id: 1} }
  let(:params_for_index) { {action: 'index', controller: controlller} }
  let(:params_for_show) { {action: 'index', controller: controlller, id: '1'} }
  let(:params_for_new) { {action: 'new', controller: controlller} }
  let(:params_for_destroy) {  {id: '1', action: 'destroy', controller: controlller} }
  let(:params_for_edit) {  {id: '1', action: 'edit', controller: controlller} }
  let(:params_for_update) { {id: '1', action: 'update', controller: controlller, model: new_attributes} }
  let(:params_for_create) { {id: nil, action: 'create', controller: controlller, model: valid_new_model } }
  let(:params_for_invalid_create) { {id: nil, action: 'create', controller: controlller, model: invalid_new_model } }
  let(:env_index) { {uri: uri, params: params_for_index, page: page_info, rout: rout_for_collection}  }
  let(:env_show) { {uri: uri, params: params_for_show, page: page_info_for_show, rout: rout_for_member}  }
  let(:env_new) { {uri: uri, params: params_for_new, page: page_info, rout: rout_for_collection}  }
  let(:env_edit) { {uri: uri, params: params_for_edit, page: page_info_for_show, rout: rout_for_member}  }
  let(:env_create) { {uri: uri, params: params_for_create, page: page_info, rout: rout_for_collection}  }
  let(:env_invalid_create) { {uri: uri, params: params_for_invalid_create, page: page_info, rout: rout_for_collection}  }
  let(:env_update) { {uri: uri, params: params_for_update, page: page_info_for_show, rout: rout_for_member}  }
  let(:env_destroy) { {uri: uri, params: params_for_destroy, page: page_info_for_show, rout: rout_for_member}  }

end
