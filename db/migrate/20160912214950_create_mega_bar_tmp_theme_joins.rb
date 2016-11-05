class CreateMegaBarTmpThemeJoins < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_theme_joins do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :theme_id
      t.integer  :themeable_id
      t.string   :themeable_type
    end
  end
end
