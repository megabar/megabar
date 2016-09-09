class AddNameToMegaBarThemes < ActiveRecord::Migration
  def change
    add_column :mega_bar_themes, :name, :string
  end
end
