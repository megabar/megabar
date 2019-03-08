class AddFilterTypeToMegaBarTmpFields < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_tmp_fields, :filter_type, :string
  end
end
