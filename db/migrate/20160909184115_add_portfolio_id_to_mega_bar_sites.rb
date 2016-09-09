class AddPortfolioIdToMegaBarSites < ActiveRecord::Migration
  def change
    add_column :mega_bar_sites, :portfolio_id, :integer
  end
end
