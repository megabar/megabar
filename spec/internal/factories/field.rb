
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :field, class: MegaBar::Field do
    model_id 1
    tablename 'mega_bar_models'
    field 'classname'
    default_data_format 'textread'
    default_data_format_edit 'textbox'
    factory :field_with_displays do
      index_field_display 'y'
      show_field_display 'y'
      new_field_display 'y'
      edit_field_display 'y'
      block_id 1
    end
  end
end
