class CreateMegaBarTmpFieldDisplays < ActiveRecord::Migration[4.2]
  def change
    create_table :mega_bar_tmp_field_displays do |t|
      t.references :model_display
      t.references :field
      t.string :format
      t.string :action
      t.string :header
      t.string :link_type
      t.string :wrapper
      t.timestamps
    end
  end
end
