class AddLayoutSectionIdToMegaBarTmpBlocks < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_blocks, :layout_section_id, :integer
  end
end
