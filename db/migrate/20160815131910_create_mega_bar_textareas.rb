class CreateMegaBarTextareas < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_textareas do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
