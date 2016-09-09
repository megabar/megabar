class CreateMegaBarSites < ActiveRecord::Migration
  def change
    create_table :mega_bar_sites do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
