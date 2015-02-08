class CreateMegaBarModelDisplayFormats < ActiveRecord::Migration
  def change
    create_table :mega_bar_model_display_formats do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
