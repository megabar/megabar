class CreateMegaBarTmpModelDisplays < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_model_displays do |t|
      t.references :block     
      t.references :model
      t.string :format
      t.string :action
      t.string :header
      t.timestamps
    end
  end
end
