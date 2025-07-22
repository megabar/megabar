class CreateProduct < ActiveRecord::Migration[8]
  def change
    create_table :products do |t|
      t.timestamps
    end
  end
end
