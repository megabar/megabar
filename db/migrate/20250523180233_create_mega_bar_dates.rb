class CreateMegaBarDates < ActiveRecord::Migration[8.0]
  def change
    create_table :mega_bar_dates do |t|
      t.timestamps
    end
  end
end
