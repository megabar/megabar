class AddFilterFieldsToMegaBarModelDisplayCollections < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_model_display_collections, :filter_fields, :boolean
  end
end
