# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :model, class: MegaBar::Model do
    id 1
    classname 'Model'
    schema  'deep'
    tablename 'mega_bar_models'
    name 'Models'
    default_sort_field 'id'
    modyule 'MegaBar'
    factory :model_with_page do
      make_page 'y'
    end
  end
end
