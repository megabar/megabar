class AddSizeToMegaBarPasswordFields < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_password_fields, :size, :integer
  end
end
