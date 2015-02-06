# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :textbox, class: MegaBar::Textbox do
    field_display_id 1
    size 43
  end
end
