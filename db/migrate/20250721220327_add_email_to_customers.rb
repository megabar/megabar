class AddEmailToCustomers < ActiveRecord::Migration[8.0]
  def change
    add_column :customers, :email, :string
  end
end
