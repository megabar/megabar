class AddFieldDisplayIdToMegaBarTmpPasswordFields < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_tmp_password_fields, :field_display_id, :integer
  end
end
