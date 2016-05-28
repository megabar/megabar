class AddOptionBorrowToMegaBarTmpFields < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_fields, :option_borrow, :integer
  end
end
