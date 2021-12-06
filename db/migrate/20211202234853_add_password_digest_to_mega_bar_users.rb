class AddPasswordDigestToMegaBarUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_users, :password_digest, :string
  end
end
