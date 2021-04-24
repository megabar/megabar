class CreateMegaBarCheckboxes < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_checkboxes do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
