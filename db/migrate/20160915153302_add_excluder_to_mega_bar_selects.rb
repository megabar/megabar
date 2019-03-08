class AddExcluderToMegaBarSelects < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_selects, :excluder, :boolean
  end
end
