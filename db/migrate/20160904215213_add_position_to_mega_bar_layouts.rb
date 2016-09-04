class AddPositionToMegaBarLayouts < ActiveRecord::Migration
  def change
    add_column :mega_bar_layouts, :position, :integer
  end
end
