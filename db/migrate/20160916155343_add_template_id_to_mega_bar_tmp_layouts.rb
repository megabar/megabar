class AddTemplateIdToMegaBarTmpLayouts < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_layouts, :template_id, :integer
  end
end
