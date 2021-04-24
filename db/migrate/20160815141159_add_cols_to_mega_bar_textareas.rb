class AddColsToMegaBarTextareas < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_textareas, :cols, :integer
  end
end
