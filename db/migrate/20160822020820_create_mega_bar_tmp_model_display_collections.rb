class CreateMegaBarTmpModelDisplayCollections < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_model_display_collections do |t|
      t.integer :model_display_id
      t.string :pagination_position
      t.string :pagination_theme
      t.integer :records_per_page
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
