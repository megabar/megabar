class CreateBeeps < ActiveRecord::Migration
  def change
    create_table :beeps do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
