class AddPermissionLevelIdToMegaBarTmpModelDisplays < ActiveRecord::Migration[6.0]
  def change
    add_column :mega_bar_tmp_model_displays, :permission_level, :integer
  end
end
