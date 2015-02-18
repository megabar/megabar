class CreateMegaBarLayouts < ActiveRecord::Migration
  def change
    create_table :mega_bar_layouts do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :page_id
      t.string :name
    end
  end
end
