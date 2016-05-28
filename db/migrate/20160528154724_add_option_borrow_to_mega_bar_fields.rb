class AddOptionBorrowToMegaBarFields < ActiveRecord::Migration
  def change
    add_column :mega_bar_fields, :option_borrow, :integer
  end
end
