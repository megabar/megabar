class CreateMegaBarTmpModelDisplayFormats < ActiveRecord::Migration
  def change
    create_table :mega_bar_tmp_model_display_formats do |t|
      t.datetime :created_at
      t.datetime :updated_at
      string :name
      string :app_wrapper
      string :app_wrapper_end
      string :field_header_wrapper
      string :field_header_wrapper_end
      string :record_wrapper
      string :record_wrapper_end
      string :field_wrapper
      string :field_wrapper_end
      string :separate_header_row
    end
  end
end
