class CreateMegaBarTmpLayoutSections < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_tmp_layout_sections do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string :code_name

    end
  end
end
