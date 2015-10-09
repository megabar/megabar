FactoryGirl.define do
  factory :option, class: MegaBar::Option do
    id 1
    field_id 1
    text 'option text'
    value 'option value'
  end
end
