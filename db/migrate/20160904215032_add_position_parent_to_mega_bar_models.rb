class AddPositionParentToMegaBarModels < ActiveRecord::Migration
  def change
    add_column :mega_bar_models, :position_parent, :string
  end
end
