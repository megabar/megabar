FactoryBot.define do
  factory :site, class: MegaBar::Site do
    name {'Test Site'}
    theme_id {1}
    portfolio_id {1}
    code_name {'test_site'}
  end
end
