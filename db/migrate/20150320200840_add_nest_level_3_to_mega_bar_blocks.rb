class AddNestLevel3ToMegaBarBlocks < ActiveRecord::Migration
  def change
    add_column :mega_bar_blocks, :nest_level_3, :integer
  end
end
