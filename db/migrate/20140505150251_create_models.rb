class CreateModels < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_models do |t|
      t.string :modyule
      t.string :classname
      t.string :schema
      t.string :tablename
      t.string :name
      t.string :default_sort_field
      t.timestamps
    end
  end
end
