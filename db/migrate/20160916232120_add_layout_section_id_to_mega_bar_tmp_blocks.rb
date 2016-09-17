class AddLayoutSectionIdToMegaBarTmpBlocks < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_blocks, :layout_section_id, :integer
  end
end
