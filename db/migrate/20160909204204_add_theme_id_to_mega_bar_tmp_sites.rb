class AddThemeIdToMegaBarTmpSites < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_sites, :theme_id, :integer
  end
end
