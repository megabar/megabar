class AddFieldDisplayIdToMegaBarTmpDates < ActiveRecord::Migration[8.0]
  def change
    add_column :mega_bar_tmp_dates, :field_display_id, :string
  end
end
