class AddDomainsToMegaBarSites < ActiveRecord::Migration
  def change
    add_column :mega_bar_sites, :domains, :string
  end
end
