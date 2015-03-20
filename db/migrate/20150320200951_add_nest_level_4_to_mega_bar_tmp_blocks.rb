class AddNestLevel4ToMegaBarTmpBlocks < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_blocks, :nest_level_4, :integer
  end
end
