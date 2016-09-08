class AddDefaultSortOrderToMegaBarTmpModels < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_models, :default_sort_order, :string
  end
end
