class AddIncludeTimeToMegaBarTmpDates < ActiveRecord::Migration[8.0]
  def change
    add_column :mega_bar_tmp_dates, :include_time, :string
  end
end
