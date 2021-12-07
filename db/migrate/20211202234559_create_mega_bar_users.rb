class CreateMegaBarUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :mega_bar_users do |t|

      t.timestamps
    end
  end
end
