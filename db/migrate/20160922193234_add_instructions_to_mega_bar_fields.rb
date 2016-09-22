class AddInstructionsToMegaBarFields < ActiveRecord::Migration
  def change
    add_column :mega_bar_fields, :instructions, :text
  end
end
