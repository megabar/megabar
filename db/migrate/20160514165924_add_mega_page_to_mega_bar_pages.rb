class AddMegaPageToMegaBarPages < ActiveRecord::Migration
  def change
    add_column :mega_bar_pages, :mega_page, :string
  end
end
