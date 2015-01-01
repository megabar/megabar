class CreateFields < ActiveRecord::Migration
  def change
    create_table :mega_bar_fields do |t|
      t.integer :model_id
      t.string :schema
      t.string :tablename
      t.string :field
      t.string :default_value
      t.timestamps
    end
  end
end
