class AddFieldDisplayIdToMegaBarSelects < ActiveRecord::Migration
  def change
    add_column :mega_bar_selects, :field_display_id, :string
  end
end
