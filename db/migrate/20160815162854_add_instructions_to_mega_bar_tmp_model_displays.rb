class AddInstructionsToMegaBarTmpModelDisplays < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_model_displays, :instructions, :text
  end
end
