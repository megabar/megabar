class CreateMegaBarIntegrationTestModels < ActiveRecord::Migration[8.0]
  def change
    create_table :mega_bar_integration_test_models do |t|
      t.timestamps
    end
  end
end
