class AddFieldDisplayIdToMegaBarTmpCheckboxes < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_checkboxes, :field_display_id, :integer
  end
end
