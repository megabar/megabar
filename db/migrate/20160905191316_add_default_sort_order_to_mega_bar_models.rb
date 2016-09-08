class AddDefaultSortOrderToMegaBarModels < ActiveRecord::Migration
  def change
    add_column :mega_bar_models, :default_sort_order, :string
  end
end
