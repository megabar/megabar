class AddDisplayIfEmptyToMegaBarTmpModelDisplayCollections < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_model_display_collections, :display_if_empty, :boolean
  end
end
