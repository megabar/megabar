class AddDisplayIfEmptyToMegaBarTmpModelDisplayCollections < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_model_display_collections, :display_if_empty, :boolean
  end
end
