class AddCheckedToMegaBarTmpCheckboxes < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_checkboxes, :checked, :boolean
  end
end
