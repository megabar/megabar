class AddLevelNameToMegaBarTmpPermissionLevels < ActiveRecord::Migration[6.0]
  def change
    add_column :mega_bar_tmp_permission_levels, :level_name, :string
  end
end
