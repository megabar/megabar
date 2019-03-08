class AddPositionToMegaBarLayouts < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_layouts, :position, :integer
  end
end
