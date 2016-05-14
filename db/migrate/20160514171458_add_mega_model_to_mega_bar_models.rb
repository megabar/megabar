class AddMegaModelToMegaBarModels < ActiveRecord::Migration
  def change
    add_column :mega_bar_models, :mega_model, :string
  end
end
