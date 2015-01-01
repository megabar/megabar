class CreateTesters < ActiveRecord::Migration
  def change
    create_table :mega_bar_testers do |t|
      t.string :one
      t.string :two
      t.string :three

      t.timestamps
    end
  end
end
