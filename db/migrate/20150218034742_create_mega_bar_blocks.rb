class CreateMegaBarBlocks < ActiveRecord::Migration
  def change
    create_table :mega_bar_blocks do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :layout_id
      t.integer :model_id
      t.string :name
    end
  end
end
