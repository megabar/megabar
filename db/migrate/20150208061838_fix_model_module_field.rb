class FixModelModuleField < ActiveRecord::Migration
  def change
    rename_column :mega_bar_models, :module, :modyule
    rename_column :mega_bar_tmp_models, :module, :modyule


  end
end
