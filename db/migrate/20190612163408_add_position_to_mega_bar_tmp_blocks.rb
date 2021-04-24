class AddPositionToMegaBarTmpBlocks < ActiveRecord::Migration[5.2]
  def change
    add_column :mega_bar_tmp_blocks, :position, :integer
  end
end
