class CreateTextreads < ActiveRecord::Migration
  def change
    create_table :mega_bar_textreads do |t|
      t.integer :field_display_id
      t.integer :truncation
      t.text :truncation_format
      t.text :transformation

      t.timestamps
    end
  end
end
