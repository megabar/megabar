class AddPositionParentToMegaBarTmpModels < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_models, :position_parent, :string
  end
end
