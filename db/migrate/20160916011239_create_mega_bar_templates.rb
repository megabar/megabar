class CreateMegaBarTemplates < ActiveRecord::Migration
  def change
    create_table :mega_bar_templates do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string :name
      t.string :code_name
    end
  end
end