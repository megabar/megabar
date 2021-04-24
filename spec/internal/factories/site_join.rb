FactoryBot.define do
  factory :site_join, class: MegaBar::SiteJoin do
    site_id {1}
    siteable_id {1}
    siteable_type {'MegaBar::Layout'}
  end
end
