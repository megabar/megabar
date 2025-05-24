class AddFormatToMegaBarTmpDates < ActiveRecord::Migration[8.0]
  def change
    add_column :mega_bar_tmp_dates, :format, :string
  end
end
