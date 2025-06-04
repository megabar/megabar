class AddTransformationToMegaBarDates < ActiveRecord::Migration[8.0]
  def change
    add_column :mega_bar_dates, :transformation, :string
  end
end
