class CreateMegaBarSelects < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_selects do |t|
      t.references :field_display
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
