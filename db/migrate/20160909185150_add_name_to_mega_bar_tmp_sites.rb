class AddNameToMegaBarTmpSites < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_sites, :name, :string
  end
end
