class AddMegaModelToMegaBarModels < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_models, :mega_model, :string
  end
end
