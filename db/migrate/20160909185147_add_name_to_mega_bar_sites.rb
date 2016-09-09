class AddNameToMegaBarSites < ActiveRecord::Migration
  def change
    add_column :mega_bar_sites, :name, :string
  end
end
