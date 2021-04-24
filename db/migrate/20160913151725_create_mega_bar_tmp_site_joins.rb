class CreateMegaBarTmpSiteJoins < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_tmp_site_joins do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :siteable_type
      t.integer  :siteable_id
      t.integer  :site_id
    end
  end
end
