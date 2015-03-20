class AddNestLevel5ToMegaBarBlocks < ActiveRecord::Migration
  def change
    add_column :mega_bar_blocks, :nest_level_5, :integer
  end
end
