class AddPasswordDigestToMegaBarTmpUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_tmp_users, :password_digest, :string
  end
end
