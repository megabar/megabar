class AddInstructionsToMegaBarTmpFields < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_fields, :instructions, :text
  end
end
