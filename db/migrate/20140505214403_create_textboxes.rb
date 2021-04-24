class CreateTextboxes < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_textboxes do |t|
      t.references :field_display
      t.integer :size
      t.timestamps
    end
  end
end
