class AddColsToMegaBarTmpTextareas < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_textareas, :cols, :integer
  end
end
