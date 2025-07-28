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
      # Use deterministic ID system - create template first, then reference it
      transient do
        template_code_name { 'default_test_template' }
      end
      
      make_page do
        # Create template with deterministic ID if it doesn't exist
        template = MegaBar::Template.find_by(code_name: template_code_name) ||
                   FactoryBot.create(:template, code_name: template_code_name)
        template.id
      end
      
      # Ensure template section exists for the template
      after(:create) do |model, evaluator|
        template = MegaBar::Template.find(model.make_page)
        unless template.template_sections.any?
          FactoryBot.create(:template_section, 
            template: template, 
            code_name: 'main_section',
            position: 1
          )
        end
      end
    end
  end
end
