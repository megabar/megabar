class CreateTextboxes < ActiveRecord::Migration
  def change
    create_table :mega_bar_textboxes do |t|
      t.integer :field_display_id
      t.integer :size

      t.timestamps
    end
  end
end
