class AddStatusToMegaBarIntegrationTestModels < ActiveRecord::Migration[8.0]
  def change
    add_column :mega_bar_integration_test_models, :status, :string
  end
end
