class AddNestLevel4ToMegaBarBlocks < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_blocks, :nest_level_4, :integer
  end
end
