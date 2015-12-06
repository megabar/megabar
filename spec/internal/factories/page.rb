FactoryGirl.define do
  factory :page, class: MegaBar::Page do
    id 1
    path '/mega-bar/models'
    name 'Factory Models Page'
    factory :page_with_all do
      make_layout_and_block = 'y'
      model_id = 1
      base_name = 'Factory Models'
    end
  end
end
