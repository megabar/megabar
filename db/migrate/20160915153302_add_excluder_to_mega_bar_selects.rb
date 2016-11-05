class AddExcluderToMegaBarSelects < ActiveRecord::Migration
  def change
    add_column :mega_bar_selects, :excluder, :boolean
  end
end
