class AddFilterTypeToMegaBarFields < ActiveRecord::Migration
  def change
    add_column :mega_bar_fields, :filter_type, :string
  end
end
