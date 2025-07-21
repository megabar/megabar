class AddNameToFieldTestModels < ActiveRecord::Migration[8.0]
  def change
    add_column :field_test_models, :name, :string
  end
end
