FactoryGirl.define do
  factory :model_display_format, class: MegaBar::ModelDisplayFormat do
    id 1
    name 'GridHtml'
    app_wrapper '<table>'
    app_wrapper_end '</table>'
    field_header_wrapper '<th>'
    field_header_wrapper_end '</th>'
    record_wrapper '<tr>'
    record_wrapper_end '</tr>'
    field_wrapper '<td>'
    field_wrapper_end '</td>'
    separate_header_row 'true'
  end
end