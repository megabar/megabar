class CreateMegaBarTmpPortfolios < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_tmp_portfolios do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :Name
      t.integer  :theme_id
      t.string   :code_name
    end
  end
end
