class CreateMegaBarLayables < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_layables do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :layout_section_id
      t.integer :template_section_id
      t.integer :layout_id
    end
  end
end
