class AddPositionToMegaBarTmpSites < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_sites, :position, :integer
  end
end
