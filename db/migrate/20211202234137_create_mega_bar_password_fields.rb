class CreateMegaBarPasswordFields < ActiveRecord::Migration[6.1]
  def change
    create_table :mega_bar_password_fields do |t|

      t.timestamps
    end
  end
end
