class AddPermissionLevelIdToMegaBarUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_users, :permission_level_id, :integer
  end
end
