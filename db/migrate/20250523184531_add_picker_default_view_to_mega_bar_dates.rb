class AddPickerDefaultViewToMegaBarDates < ActiveRecord::Migration[8.0]
  def change
    add_column :mega_bar_dates, :picker_default_view, :string
  end
end
