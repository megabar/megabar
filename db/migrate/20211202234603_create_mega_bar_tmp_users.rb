class CreateMegaBarTmpUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :mega_bar_tmp_users do |t|

      t.timestamps
    end
  end
end
