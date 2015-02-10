# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :model, class: MegaBar::Model do
    id 1
    classname 'Model'
    schema  'deep'
    tablename 'mega_bar_models'
    name 'Models'
    default_sort_field 'id'
    modyule 'MegaBar'
    factory :model_with_model_displays do
      index_model_display 'y'
      show_model_display 'y'
      new_model_display 'y'
      edit_model_display 'y'
    end 
     # after(:create) do 
     #   create(:field_with_displays, model_id: 1, tablename: 'models', field: 'id')
     #   create(:field_with_displays, model_id: 1, tablename: 'models', field: 'classname')
     # end
    # end
  end
end
