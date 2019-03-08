class AddCheckedToMegaBarCheckboxes < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_checkboxes, :checked, :boolean
  end
end
