class CreateMegaBarTmpTextreads < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_tmp_textreads do |t|
      t.references :field_display
      t.integer :truncation
      t.text :truncation_format
      t.text :transformation

      t.timestamps
    end
  end
end
