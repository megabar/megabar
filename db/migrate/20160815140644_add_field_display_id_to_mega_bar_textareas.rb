class AddFieldDisplayIdToMegaBarTextareas < ActiveRecord::Migration
  def change
    add_column :mega_bar_textareas, :field_display_id, :integer
  end
end
