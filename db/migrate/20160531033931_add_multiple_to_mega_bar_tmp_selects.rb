class AddMultipleToMegaBarTmpSelects < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_selects, :multiple, :boolean
  end
end
