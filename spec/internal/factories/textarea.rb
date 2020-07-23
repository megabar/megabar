# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :textarea, class: MegaBar::Textarea do
    field_display_id {1}
    rows {42}
    cols {50}
  end
end
