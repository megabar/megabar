class AddIncludeTimeToMegaBarDates < ActiveRecord::Migration[7.0]  # or whatever Rails version you're using
  def change
    add_column :mega_bar_dates, :include_time, :boolean, default: false
  end
end