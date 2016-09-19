class AddCssFrameworkToMegaBarTmpLayouts < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_layouts, :css_framework, :string
  end
end
