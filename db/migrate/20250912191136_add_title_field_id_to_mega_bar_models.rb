class AddTitleFieldIdToMegaBarModels < ActiveRecord::Migration[8.0]
  def change
    add_column :mega_bar_models, :title_field_id, :integer
  end
end
