class CreateMegaBarTmpOptions < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_tmp_options do |t|
      t.references :field
      t.string   :text
      t.string   :value
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
