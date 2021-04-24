class AddMultipleToMegaBarSelects < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_selects, :multiple, :boolean
  end
end
