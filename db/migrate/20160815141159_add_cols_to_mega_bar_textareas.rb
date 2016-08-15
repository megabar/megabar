class AddColsToMegaBarTextareas < ActiveRecord::Migration
  def change
    add_column :mega_bar_textareas, :cols, :integer
  end
end
