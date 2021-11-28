class AddLevelNameToMegaBarPermissionLevels < ActiveRecord::Migration[6.0]
  def change
    add_column :mega_bar_permission_levels, :level_name, :string
  end
end
