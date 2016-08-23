class AddFilterFieldsToMegaBarTmpModelDisplayCollections < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_model_display_collections, :filter_fields, :boolean
  end
end
