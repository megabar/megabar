class AddMultipleToMegaBarTmpSelects < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_selects, :multiple, :boolean
  end
end
