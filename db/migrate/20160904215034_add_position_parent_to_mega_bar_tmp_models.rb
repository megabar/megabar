class AddPositionParentToMegaBarTmpModels < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_models, :position_parent, :string
  end
end
