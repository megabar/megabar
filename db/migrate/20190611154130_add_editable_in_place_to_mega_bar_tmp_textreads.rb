class AddEditableInPlaceToMegaBarTmpTextreads < ActiveRecord::Migration[5.2]
  def change
    add_column :mega_bar_tmp_textreads, :editable_in_place, :boolean
  end
end
