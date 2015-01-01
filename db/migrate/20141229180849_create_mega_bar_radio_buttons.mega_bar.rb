class CreateMegaBarRadioButtons < ActiveRecord::Migration
  def change
    create_table :mega_bar_radio_buttons do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
