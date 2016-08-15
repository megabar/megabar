class AddRowsToMegaBarTextareas < ActiveRecord::Migration
  def change
    add_column :mega_bar_textareas, :rows, :integer
  end
end
