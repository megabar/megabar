FactoryBot.define do
  factory :portfolio, class: MegaBar::Portfolio do
    Name {'Test Portfolio'}
    code_name {'test_portfolio'}
    theme_id { 1}
  end
end
