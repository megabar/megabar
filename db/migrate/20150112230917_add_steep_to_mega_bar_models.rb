class AddSteepToMegaBarModels < ActiveRecord::Migration
  def change
    add_column :mega_bar_models, :steep, :string
    add_column :mega_bar_tmp_models, :steep, :string
  end
end
