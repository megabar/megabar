class AddToolTipToMegaBarFields < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_fields, :tool_tip, :text
  end
end
