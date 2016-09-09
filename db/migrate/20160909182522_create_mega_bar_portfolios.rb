class CreateMegaBarPortfolios < ActiveRecord::Migration
  def change
    create_table :mega_bar_portfolios do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
