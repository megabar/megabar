# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :select, class: MegaBar::Select do
    field_display_id 1
  end
end
