class AddPickerMinDateToMegaBarTmpDates < ActiveRecord::Migration[8.0]
  def change
    add_column :mega_bar_tmp_dates, :picker_min_date, :datetime
  end
end
