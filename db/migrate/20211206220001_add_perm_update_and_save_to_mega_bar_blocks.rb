class AddPermUpdateAndSaveToMegaBarBlocks < ActiveRecord::Migration[6.1]
  # note this was manually changed here to be permEditAndSave. 
  def change
    add_column :mega_bar_blocks, :permEditAndSave, :integer
  end
end
