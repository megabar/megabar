# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :model, class: MegaBar::Model do
    classname {'Model'}
    schema  {'deeper'}
    tablename {'mega_bar_models'}
    name {'Models'}
    default_sort_field {'id'}
    modyule {'MegaBar'}
    default_sort_order {'desc'}
    # Let deterministic ID system handle the ID
    
    factory :model_with_page do
      # This will be set by the test to use the actual created template
      make_page { 1 }  # Default fallback, should be overridden in tests
    end
  end
end
