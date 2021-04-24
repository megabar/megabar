class AddFieldDisplayIdToMegaBarCheckboxes < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_checkboxes, :field_display_id, :integer
  end
end
