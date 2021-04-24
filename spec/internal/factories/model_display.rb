# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :model_display, class: MegaBar::ModelDisplay do
    model_id {1}
    block_id {1}
    action {'index'}
    header {'Hi there, I am a model display'}
    format {1}
  end
end
