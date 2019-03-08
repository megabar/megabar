class CreateMegaBarLayouts < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_layouts do |t|
      t.references :page
      t.string :name
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
