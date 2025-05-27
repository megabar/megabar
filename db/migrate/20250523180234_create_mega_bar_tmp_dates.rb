class CreateMegaBarTmpDates < ActiveRecord::Migration[8.0]
  def change
    create_table :mega_bar_tmp_dates do |t|
      t.timestamps
    end
  end
end
