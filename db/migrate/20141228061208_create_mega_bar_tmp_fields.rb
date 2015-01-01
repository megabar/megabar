class CreateMegaBarTmpFields < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_fields do |t|
      t.integer :model_id
      t.string :schema
      t.string :tablename
      t.string :field
      t.string :default_value
      t.timestamps
    end
  end
end
