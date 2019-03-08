class AddFieldDisplayIdToMegaBarTmpTextareas < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_textareas, :field_display_id, :integer
  end
end
