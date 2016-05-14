class AddMegaModelToMegaBarTmpModels < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_models, :mega_model, :string
  end
end
