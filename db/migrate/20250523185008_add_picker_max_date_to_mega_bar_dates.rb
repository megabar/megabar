class AddPickerMaxDateToMegaBarDates < ActiveRecord::Migration[8.0]
  def change
    add_column :mega_bar_dates, :picker_max_date, :datetime
  end
end
