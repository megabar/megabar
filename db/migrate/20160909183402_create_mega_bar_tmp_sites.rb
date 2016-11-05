class CreateMegaBarTmpSites < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_sites do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :position
      t.integer  :portfolio_id
      t.string   :name
      t.integer  :theme_id
      t.string   :code_name
    end
  end
end
