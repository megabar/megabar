class CreateMegaBarTmpSelects < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_selects do |t|
      t.references :field_display
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
