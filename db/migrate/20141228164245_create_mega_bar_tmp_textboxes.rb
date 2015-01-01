class CreateMegaBarTmpTextboxes < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_textboxes do |t|
      t.integer :field_display_id
      t.integer :size

      t.timestamps
    end
  end
end
