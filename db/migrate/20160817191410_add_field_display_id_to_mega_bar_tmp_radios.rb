class AddFieldDisplayIdToMegaBarTmpRadios < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_radios, :field_display_id, :integer
  end
end