class CreateRecordsFormats < ActiveRecord::Migration
  def change
    create_table :mega_bar_records_formats do |t|
      t.string :name
      t.string :classname
      t.string :type

      t.timestamps
    end
  end
end
