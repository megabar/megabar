class CreateMegaBarSelects < ActiveRecord::Migration
  def change
    create_table :mega_bar_selects do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
