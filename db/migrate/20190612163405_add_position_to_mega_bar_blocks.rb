class AddPositionToMegaBarBlocks < ActiveRecord::Migration[5.2]
  def change
    add_column :mega_bar_blocks, :position, :integer
  end
end
