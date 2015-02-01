# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :field, class: MegaBar::Field do
    model_id '1'
    tablename 'models'
    field 'classname'   
    factory :field_with_displays do
      index_field_display 'y'
      show_field_display 'y'
      new_field_display 'y'
      edit_field_display 'y'
    end
    factory :field_for_model_model do
      model_id '1'
      tablename 'models'
      field 'classname'
    end
    factory :tablename_field_for_field_model do
      model_id '1' # because theres no model model
      tablename 'fields'
      field 'tablename'
    end
     factory :model_id_field_for_field_model do
      model_id '1' # because theres no model model
      tablename 'fields'
      field 'model_id'
    end
     factory :field_field_for_field_model do
      model_id '1' # because theres no model model
      tablename 'fields'
      field 'field'
    end
  end
end
