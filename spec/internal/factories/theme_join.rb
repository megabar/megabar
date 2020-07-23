FactoryBot.define do
  factory :theme_join, class: MegaBar::ThemeJoin do
    theme_id {1}
    themeable_id {1}
    themeable_type {'MegaBar::Layout'}
  end
end
