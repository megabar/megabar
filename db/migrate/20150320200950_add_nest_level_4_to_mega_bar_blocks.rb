class AddNestLevel4ToMegaBarBlocks < ActiveRecord::Migration
  def change
    add_column :mega_bar_blocks, :nest_level_4, :integer
  end
end
