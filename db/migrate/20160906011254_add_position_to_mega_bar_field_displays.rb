class AddPositionToMegaBarFieldDisplays < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_field_displays, :position, :integer
  end
end
