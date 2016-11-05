class AddTemplateIdToMegaBarTmpLayouts < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_layouts, :template_id, :integer
  end
end
