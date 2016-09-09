class AddThemeIdToMegaBarSites < ActiveRecord::Migration
  def change
    add_column :mega_bar_sites, :theme_id, :integer
  end
end
