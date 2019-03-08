class AddExcluderToMegaBarTmpSelects < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_selects, :excluder, :boolean
  end
end
