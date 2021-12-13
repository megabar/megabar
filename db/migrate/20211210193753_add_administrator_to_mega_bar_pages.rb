class AddAdministratorToMegaBarPages < ActiveRecord::Migration[6.1]
  def change
    add_column :mega_bar_pages, :administrator, :integer
  end
end
