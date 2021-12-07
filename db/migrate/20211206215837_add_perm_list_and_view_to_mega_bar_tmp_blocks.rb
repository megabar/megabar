class AddPermListAndViewToMegaBarTmpBlocks < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_tmp_blocks, :permListAndView, :integer
  end
end
