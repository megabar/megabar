FactoryBot.define do
  factory :model_display_collection, class: MegaBar::ModelDisplayCollection do
    model_display_id {1}
    pagination_position {'both'}
    pagination_theme {'standard'}
    records_per_page {5}
  end
end
