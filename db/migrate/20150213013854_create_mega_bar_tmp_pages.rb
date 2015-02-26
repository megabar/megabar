class CreateMegaBarTmpPages < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_pages do |t|
      t.string :name
      t.string :path
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
