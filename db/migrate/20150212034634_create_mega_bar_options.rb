class CreateMegaBarOptions < ActiveRecord::Migration
  def change
    create_table :mega_bar_options do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string :field_id
      t.string   :text
      t.string   :value
    end
  end
end
