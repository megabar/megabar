class AddInstructionsToMegaBarTmpFields < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_fields, :instructions, :text
  end
end
