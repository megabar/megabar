class CreateMegaBarTmpTemplates < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_tmp_templates do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string :name
      t.string :code_name
    end
  end
end
