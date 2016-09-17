class AddTemplateIdToMegaBarLayouts < ActiveRecord::Migration
  def change
    add_column :mega_bar_layouts, :template_id, :integer
  end
end
