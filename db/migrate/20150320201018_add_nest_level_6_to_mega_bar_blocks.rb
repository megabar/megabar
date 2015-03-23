class AddNestLevel6ToMegaBarBlocks < ActiveRecord::Migration
  def change
    add_column :mega_bar_blocks, :nest_level_6, :integer
  end
end
