class AddExcluderToMegaBarTmpSelects < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_selects, :excluder, :boolean
  end
end
