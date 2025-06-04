class AddFieldDisplayIdToMegaBarDates < ActiveRecord::Migration[8.0]
  def change
    add_column :mega_bar_dates, :field_display_id, :integer
  end
end
