class CreateMegaBarTmpBlocks < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_blocks do |t|
      t.references :layout
      t.references :model
      t.string :name
      t.string :actions
      t.text :html
      t.integer :nest_level_1
      t.integer :nest_level_2
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
