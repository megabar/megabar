# This migration comes from mega_bar (originally 20141229173832)
class CreateMegaBarCheckboxes < ActiveRecord::Migration
  def change
    create_table :mega_bar_checkboxes do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
