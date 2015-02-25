class CreateMegaBarTmpModelDisplayFormats < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_model_display_formats do |t|
      t.string :name
      t.string :app_wrapper
      t.string :app_wrapper_end
      t.string :field_header_wrapper
      t.string :field_header_wrapper_end
      t.string :record_wrapper
      t.string :record_wrapper_end
      t.string :field_wrapper
      t.string :field_wrapper_end
      t.string :separate_header_row
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
