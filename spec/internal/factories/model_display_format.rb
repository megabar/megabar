FactoryBot.define do
  factory :model_display_format, class: MegaBar::ModelDisplayFormat do
    id { 1}
    name {'grid'}
    factory :model_display_format_2 do
      id {2}
      name {'profile'}
    end
  end
end
