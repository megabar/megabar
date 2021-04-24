class CreateMegaBarPages < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_pages do |t|
      t.string :name
      t.string :path
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
