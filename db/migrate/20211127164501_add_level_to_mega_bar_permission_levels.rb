class AddLevelToMegaBarPermissionLevels < ActiveRecord::Migration[6.0]
  def change
    add_column :mega_bar_permission_levels, :level, :integer
  end
end
