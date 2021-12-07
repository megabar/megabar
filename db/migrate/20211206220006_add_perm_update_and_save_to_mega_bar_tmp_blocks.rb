class AddPermUpdateAndSaveToMegaBarTmpBlocks < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_tmp_blocks, :permEditAndSave, :integer
  end
end
