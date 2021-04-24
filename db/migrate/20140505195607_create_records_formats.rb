class CreateRecordsFormats < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_records_formats do |t|
      t.string :name
      t.string :classname
      t.string :type
      t.timestamps
    end
  end
end
