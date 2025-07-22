class AddPriceToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :price, :string
  end
end
