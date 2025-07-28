FactoryBot.define do
  factory :block, class: MegaBar::Block do
    name {'test block'}
    layout_section_id {1}  # This will be used for deterministic ID calculation
    # Let deterministic ID system handle the ID
  end
end
