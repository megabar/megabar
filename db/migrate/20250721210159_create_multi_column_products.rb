class CreateMultiColumnProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :multi_column_products do |t|
      t.timestamps
    end
  end
end
