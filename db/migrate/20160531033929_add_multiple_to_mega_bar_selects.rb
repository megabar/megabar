class AddMultipleToMegaBarSelects < ActiveRecord::Migration
  def change
    add_column :mega_bar_selects, :multiple, :boolean
  end
end
