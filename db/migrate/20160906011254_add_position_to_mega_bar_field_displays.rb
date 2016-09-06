class AddPositionToMegaBarFieldDisplays < ActiveRecord::Migration
  def change
    add_column :mega_bar_field_displays, :position, :integer
  end
end
