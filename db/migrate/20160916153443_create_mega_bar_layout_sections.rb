class CreateMegaBarLayoutSections < ActiveRecord::Migration
  def change
    create_table :mega_bar_layout_sections do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string :code_name

    end
  end
end