class CreateTestCases < ActiveRecord::Migration
  def change
    create_table :test_cases do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
