class CreateTests < ActiveRecord::Migration
  def change
    create_table :mega_bar_tests do |t|
      t.string :name

      t.timestamps
    end
  end
end
