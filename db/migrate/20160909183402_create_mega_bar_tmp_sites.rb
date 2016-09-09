class CreateMegaBarTmpSites < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_sites do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
