class AddEmailToMegaBarTmpUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_tmp_users, :email, :string
  end
end
