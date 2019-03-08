class CreateMegaBarModelDisplayCollections < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_model_display_collections do |t|
      t.references :model_display
      t.string :pagination_position
      t.string :pagination_theme
      t.integer :records_per_page
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
