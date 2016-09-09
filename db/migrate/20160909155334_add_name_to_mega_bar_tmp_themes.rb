class AddNameToMegaBarTmpThemes < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_themes, :name, :string
  end
end
