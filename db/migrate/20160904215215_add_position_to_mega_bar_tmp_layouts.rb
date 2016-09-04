class AddPositionToMegaBarTmpLayouts < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_layouts, :position, :integer
  end
end
