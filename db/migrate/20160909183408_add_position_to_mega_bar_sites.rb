class AddPositionToMegaBarSites < ActiveRecord::Migration
  def change
    add_column :mega_bar_sites, :position, :integer
  end
end
