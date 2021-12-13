class AddAdministratorToMegaBarTmpBlocks < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_tmp_blocks, :administrator, :integer
  end
end
