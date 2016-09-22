class AddToolTipToMegaBarFields < ActiveRecord::Migration
  def change
    add_column :mega_bar_fields, :tool_tip, :text
  end
end
