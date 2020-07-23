# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :model, class: MegaBar::Model do

    id {1}
    classname {'Model'}
    schema  {'deeper'}
    tablename {'mega_bar_models'}
    name {'Models'}
    default_sort_field {'id'}
    modyule {'MegaBar'}
    default_sort_order {'desc'}
    factory :model_with_page do
      make_page 1
    end
  end
end
