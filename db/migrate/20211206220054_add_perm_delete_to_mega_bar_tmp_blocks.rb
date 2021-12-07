class AddPermDeleteToMegaBarTmpBlocks < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_tmp_blocks, :permDelete, :integer
  end
end
