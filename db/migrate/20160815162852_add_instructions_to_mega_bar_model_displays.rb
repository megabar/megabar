class AddInstructionsToMegaBarModelDisplays < ActiveRecord::Migration
  def change
    add_column :mega_bar_model_displays, :instructions, :text
  end
end
