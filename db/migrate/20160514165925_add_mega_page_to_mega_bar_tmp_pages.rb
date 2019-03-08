class AddMegaPageToMegaBarTmpPages < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_pages, :mega_page, :string
  end
end
