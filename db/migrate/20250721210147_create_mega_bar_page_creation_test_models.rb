class CreateMegaBarPageCreationTestModels < ActiveRecord::Migration[8.0]
  def change
    create_table :mega_bar_page_creation_test_models do |t|
      t.timestamps
    end
  end
end
