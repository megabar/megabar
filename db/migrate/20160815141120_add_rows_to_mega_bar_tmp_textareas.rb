class AddRowsToMegaBarTmpTextareas < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_textareas, :rows, :integer
  end
end
