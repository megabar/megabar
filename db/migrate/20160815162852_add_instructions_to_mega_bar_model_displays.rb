class AddInstructionsToMegaBarModelDisplays < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_model_displays, :instructions, :text
  end
end
