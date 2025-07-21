class CreateSimpleModels < ActiveRecord::Migration[8.0]
  def change
    create_table :simple_models do |t|
      t.timestamps
    end
  end
end
