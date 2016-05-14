class AddMegaPageToMegaBarTmpPages < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_pages, :mega_page, :string
  end
end
