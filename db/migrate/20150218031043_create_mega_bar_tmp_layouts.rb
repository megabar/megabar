class CreateMegaBarTmpLayouts < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_tmp_layouts do |t|
      t.references :page
      t.string :name
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
