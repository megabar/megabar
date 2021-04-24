FactoryBot.define do
  factory :layable, class: MegaBar::Layable do
    layout_id { 1}
    layout_section_id {1}
    template_section_id {1}
  end
end
