# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :field, class: MegaBar::Field do
   
    factory :field_with_displays do
      index_field_display 'y'
      show_field_display 'y'
      new_field_display 'y'
      edit_field_display 'y'
    end
  end
end
