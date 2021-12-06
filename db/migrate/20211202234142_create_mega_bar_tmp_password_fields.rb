class CreateMegaBarTmpPasswordFields < ActiveRecord::Migration[6.1]
  def change
    create_table :mega_bar_tmp_password_fields do |t|

      t.timestamps
    end
  end
end
