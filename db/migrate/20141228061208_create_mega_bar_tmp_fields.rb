class CreateMegaBarTmpFields < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_tmp_fields do |t|
      t.references :model
      t.string :schema
      t.string :tablename
      t.string :field
      t.string :data_type
      t.string :accessor
      t.string :default_value
      t.string :default_data_format
      t.string :default_data_format_edit
      t.string :default_index_wrapper
      t.string :default_show_wrapper
      t.timestamps
    end
  end
end
