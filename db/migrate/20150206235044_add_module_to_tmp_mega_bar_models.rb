class AddModuleToTmpMegaBarModels < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_models, :module, :string
  end
end
