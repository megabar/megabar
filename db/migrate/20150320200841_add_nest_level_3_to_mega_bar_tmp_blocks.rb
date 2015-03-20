class AddNestLevel3ToMegaBarTmpBlocks < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_blocks, :nest_level_3, :integer
  end
end
