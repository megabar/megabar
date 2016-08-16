class AddColsToMegaBarTmpTextareas < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_textareas, :cols, :integer
  end
end
