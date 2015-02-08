class AddModuleToMegaBarModels < ActiveRecord::Migration
  def change
    add_column :mega_bar_models, :module, :string
  end
end
