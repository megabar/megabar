# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :records_format, class: MegaBar::RecordsFormat do
    name 'GridHtml'
    classname 'GridHtml'
  end
end
