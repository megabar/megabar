class CreateMegaBarModelDisplayCollections < ActiveRecord::Migration
  def change
    create_table :mega_bar_model_display_collections do |t|
      t.belongs_to :model_display, index: true, unique: true, foreign_key: true
      t.string :pagination_position
      t.string :pagination_theme
      t.integer :records_per_page
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
