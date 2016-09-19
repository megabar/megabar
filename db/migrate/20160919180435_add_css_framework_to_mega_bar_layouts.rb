class AddCssFrameworkToMegaBarLayouts < ActiveRecord::Migration
  def change
    add_column :mega_bar_layouts, :css_framework, :string
  end
end
