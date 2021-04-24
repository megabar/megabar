class CreateMegaBarTmpTemplateSections < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_tmp_template_sections do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :position
      t.string :name
      t.string :code_name
      t.integer :template_id
    end
  end
end
