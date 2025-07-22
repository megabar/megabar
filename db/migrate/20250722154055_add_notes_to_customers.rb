class AddNotesToCustomers < ActiveRecord::Migration[8.0]
  def change
    add_column :customers, :notes, :text
  end
end
