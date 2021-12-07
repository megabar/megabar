class AddRulesToMegaBarTmpLayoutSections < ActiveRecord::Migration[6.0]
  def change
    add_column :mega_bar_tmp_layout_sections, :rules, :string
  end
end
