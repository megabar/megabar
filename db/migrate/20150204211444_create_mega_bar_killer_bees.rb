class CreateMegaBarKillerBees < ActiveRecord::Migration
  def change
    create_table :mega_bar_killer_bees do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
