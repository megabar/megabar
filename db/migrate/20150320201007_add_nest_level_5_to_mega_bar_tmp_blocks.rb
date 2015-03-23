class AddNestLevel5ToMegaBarTmpBlocks < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_blocks, :nest_level_5, :integer
  end
end
