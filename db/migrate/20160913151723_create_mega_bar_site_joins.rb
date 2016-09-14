class CreateMegaBarSiteJoins < ActiveRecord::Migration
  def change
    create_table :mega_bar_site_joins do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :siteable_type
      t.integer  :siteable_id
      t.integer  :site_id
    end
    add_index :mega_bar_site_joins, [:siteable_id, :siteable_type]
  end
end
