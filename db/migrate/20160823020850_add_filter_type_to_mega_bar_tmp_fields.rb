class AddFilterTypeToMegaBarTmpFields < ActiveRecord::Migration
  def change
    add_column :mega_bar_tmp_fields, :filter_type, :string
  end
end
