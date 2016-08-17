class AddCheckedToMegaBarCheckboxes < ActiveRecord::Migration
  def change
    add_column :mega_bar_checkboxes, :checked, :boolean
  end
end
