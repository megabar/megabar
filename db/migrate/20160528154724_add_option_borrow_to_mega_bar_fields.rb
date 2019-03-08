class AddOptionBorrowToMegaBarFields < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_fields, :option_borrow, :integer
  end
end
