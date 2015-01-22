class CreateFieldDisplays < ActiveRecord::Migration
  def change
    create_table :mega_bar_field_displays do |t|
      t.integer :field_id
      t.string :format
      t.string :action
      t.string :header
      t.integer :model_display_id
      t.timestamps
    end
  end
end
