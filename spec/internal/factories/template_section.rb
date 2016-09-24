FactoryGirl.define do
  factory :template_section, class: MegaBar::TemplateSection do
    template_id 1
    position 1
    name 'main'
    code_name 'main'
  end
end
