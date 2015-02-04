# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :textread, class: MegaBar::Textread do
    id 1
    field_display_id 1
    truncation 200
    truncation_format 'elipsis'
    transformation 'none'
  end
end
