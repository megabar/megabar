class CreateModelDisplays < ActiveRecord::Migration
  def change
    create_table :mega_bar_model_displays do |t|
      t.integer :model_id
      t.string :format
      t.string :action
      t.string :header
      t.timestamps
    end
  end
end
