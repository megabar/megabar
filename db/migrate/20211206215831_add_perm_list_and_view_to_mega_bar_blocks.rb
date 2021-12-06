class AddPermListAndViewToMegaBarBlocks < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_blocks, :permListAndView, :integer
  end
end
