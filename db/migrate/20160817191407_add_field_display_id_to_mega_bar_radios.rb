class AddFieldDisplayIdToMegaBarRadios < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_radios, :field_display_id, :integer
  end
end
