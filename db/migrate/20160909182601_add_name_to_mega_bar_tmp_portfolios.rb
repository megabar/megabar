class AddNameToMegaBarTmpPortfolios < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_portfolios, :Name, :string
  end
end
