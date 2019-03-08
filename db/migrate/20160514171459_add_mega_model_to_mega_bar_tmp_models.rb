class AddMegaModelToMegaBarTmpModels < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_models, :mega_model, :string
  end
end
