class AddLayoutSectionIdToMegaBarBlocks < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_blocks, :layout_section_id, :integer
  end
end
