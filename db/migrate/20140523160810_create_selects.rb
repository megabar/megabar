class CreateSelects < ActiveRecord::Migration
  def change
    create_table :mega_bar_selects do |t|
      t.integer :field_display_id
      t.integer :model_id
      t.integer :field_id
      t.string :collection
      t.string :value_method
      t.string :text_method
      t.integer :data_size
      t.string :include_blank

      t.timestamps
    end
  end
end
