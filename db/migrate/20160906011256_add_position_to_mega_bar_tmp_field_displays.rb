class AddPositionToMegaBarTmpFieldDisplays < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_field_displays, :position, :integer
  end
end
