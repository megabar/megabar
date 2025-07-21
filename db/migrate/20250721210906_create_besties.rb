class CreateBesties < ActiveRecord::Migration[8.0]
  def change
    create_table :besties do |t|
      t.timestamps
    end
  end
end
