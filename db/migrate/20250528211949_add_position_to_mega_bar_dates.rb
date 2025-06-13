class AddPositionToMegaBarDates < ActiveRecord::Migration[8.0]
  def change
    add_column :mega_bar_dates, :position, :integer
  end
end
