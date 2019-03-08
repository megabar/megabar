class AddNestLevel6ToMegaBarTmpBlocks < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_blocks, :nest_level_6, :integer
  end
end
