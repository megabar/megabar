class AddSizeToMegaBarTmpPasswordFields < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_tmp_password_fields, :size, :integer
  end
end
