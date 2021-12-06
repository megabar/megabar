class AddEmailToMegaBarUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_users, :email, :string
  end
end
