class CreateMegaBarAuthorizationTestModels < ActiveRecord::Migration[8.0]
  def change
    create_table :mega_bar_authorization_test_models do |t|
      t.timestamps
    end
  end
end
