class CreateMegaBarThemeJoins < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_theme_joins do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :theme_id
      t.integer  :themeable_id
      t.string   :themeable_type
    end
    add_index :mega_bar_theme_joins, [:themeable_id, :themeable_type]
  end
end
