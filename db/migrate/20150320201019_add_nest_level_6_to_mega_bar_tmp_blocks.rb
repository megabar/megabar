class AddNestLevel6ToMegaBarTmpBlocks < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_blocks, :nest_level_6, :integer
  end
end
