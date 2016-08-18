class AddFieldDisplayIdToMegaBarRadios < ActiveRecord::Migration
  def change
    add_column :mega_bar_radios, :field_display_id, :integer
  end
end
