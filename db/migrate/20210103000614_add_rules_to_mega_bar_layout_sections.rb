class AddRulesToMegaBarLayoutSections < ActiveRecord::Migration[6.0]
  def change
    add_column :mega_bar_layout_sections, :rules, :string
  end
end
