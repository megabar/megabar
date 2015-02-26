class CreateMegaBarTmpTextboxes < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_textboxes do |t|
      t.references :field_display
      t.integer :size

      t.timestamps
    end
  end
end
