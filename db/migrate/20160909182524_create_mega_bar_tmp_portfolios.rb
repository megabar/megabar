class CreateMegaBarTmpPortfolios < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_portfolios do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :Name
    end
  end
end
