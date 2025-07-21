FactoryBot.define do
  factory :template, class: MegaBar::Template do
    name {'a template'}
    code_name {'a_template'}
    # Let deterministic ID system handle the ID
  end
end
