class CreateFieldTestModels < ActiveRecord::Migration[8.0]
  def change
    create_table :field_test_models do |t|
      t.timestamps
    end
  end
end
