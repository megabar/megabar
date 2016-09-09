class AddPortfolioIdToMegaBarTmpSites < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_sites, :portfolio_id, :integer
  end
end
