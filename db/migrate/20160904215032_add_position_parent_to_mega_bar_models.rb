class AddPositionParentToMegaBarModels < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_models, :position_parent, :string
  end
end
