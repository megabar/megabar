class AddFilterTypeToMegaBarFields < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_fields, :filter_type, :string
  end
end
