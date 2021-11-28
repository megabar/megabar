class CreateMegaBarTmpPermissionLevels < ActiveRecord::Migration[6.0]
  def change
    create_table :mega_bar_tmp_permission_levels do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
