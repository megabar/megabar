class AddDomainsToMegaBarSites < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_sites, :domains, :string
  end
end
