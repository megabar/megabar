class AddNameToMegaBarPortfolios < ActiveRecord::Migration
  def change
    add_column :mega_bar_portfolios, :Name, :string
  end
end
