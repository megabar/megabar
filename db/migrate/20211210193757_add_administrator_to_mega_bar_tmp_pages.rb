class AddAdministratorToMegaBarTmpPages < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_tmp_pages, :administrator, :integer
  end
end
