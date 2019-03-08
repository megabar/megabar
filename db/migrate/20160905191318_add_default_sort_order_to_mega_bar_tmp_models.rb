class AddDefaultSortOrderToMegaBarTmpModels < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_models, :default_sort_order, :string
  end
end
