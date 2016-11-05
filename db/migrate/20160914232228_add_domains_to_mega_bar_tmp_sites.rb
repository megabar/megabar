class AddDomainsToMegaBarTmpSites < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_sites, :domains, :string
  end
end
