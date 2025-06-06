class CreateMegaBarBlocks < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_blocks do |t|
      t.references :layout
      t.references :model
      t.string :name
      t.string :actions
      t.text :html
      t.integer :nest_level_1
      t.integer :nest_level_2
      t.string :path_base
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
