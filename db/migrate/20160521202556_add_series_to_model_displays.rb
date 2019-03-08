class AddSeriesToModelDisplays < ActiveRecord::Migration[4.2]
  def change
    add_column :mega_bar_model_displays, :series, :integer
    add_column :mega_bar_tmp_model_displays, :series, :integer
  end
end
