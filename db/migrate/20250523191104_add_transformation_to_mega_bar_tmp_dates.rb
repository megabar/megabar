class AddTransformationToMegaBarTmpDates < ActiveRecord::Migration[8.0]
  def change
    add_column :mega_bar_tmp_dates, :transformation, :string
  end
end
