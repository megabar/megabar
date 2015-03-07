# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150227161746) do

  create_table "mega_bar_blocks", force: true do |t|
    t.integer  "layout_id"
    t.integer  "model_id"
    t.string   "name"
    t.string   "actions"
    t.text     "html"
    t.integer  "nest_level_1"
    t.integer  "nest_level_2"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "path_base"
  end

  create_table "mega_bar_field_displays", force: true do |t|
    t.integer  "model_display_id"
    t.integer  "field_id"
    t.string   "format"
    t.string   "action"
    t.string   "header"
    t.string   "link_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_fields", force: true do |t|
    t.integer  "model_id"
    t.string   "schema"
    t.string   "tablename"
    t.string   "field"
    t.string   "data_type"
    t.string   "accessor"
    t.string   "default_value"
    t.string   "default_data_format"
    t.string   "default_data_format_edit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_layouts", force: true do |t|
    t.integer  "page_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_model_display_formats", force: true do |t|
    t.string   "name"
    t.string   "app_wrapper"
    t.string   "app_wrapper_end"
    t.string   "field_header_wrapper"
    t.string   "field_header_wrapper_end"
    t.string   "record_wrapper"
    t.string   "record_wrapper_end"
    t.string   "field_wrapper"
    t.string   "field_wrapper_end"
    t.string   "separate_header_row"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_model_displays", force: true do |t|
    t.integer  "block_id"
    t.integer  "model_id"
    t.string   "format"
    t.string   "action"
    t.string   "header"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_models", force: true do |t|
    t.string   "modyule"
    t.string   "classname"
    t.string   "schema"
    t.string   "tablename"
    t.string   "name"
    t.string   "default_sort_field"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_options", force: true do |t|
    t.integer  "field_id"
    t.string   "text"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_pages", force: true do |t|
    t.string   "name"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_records_formats", force: true do |t|
    t.string   "name"
    t.string   "classname"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_selects", force: true do |t|
    t.integer  "field_display_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_textboxes", force: true do |t|
    t.integer  "field_display_id"
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_textreads", force: true do |t|
    t.integer  "field_display_id"
    t.integer  "truncation"
    t.text     "truncation_format"
    t.text     "transformation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_tmp_blocks", force: true do |t|
    t.integer  "layout_id"
    t.integer  "model_id"
    t.string   "name"
    t.string   "actions"
    t.text     "html"
    t.integer  "nest_level_1"
    t.integer  "nest_level_2"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "path_base"
  end

  create_table "mega_bar_tmp_field_displays", force: true do |t|
    t.integer  "model_display_id"
    t.integer  "field_id"
    t.string   "format"
    t.string   "action"
    t.string   "header"
    t.string   "link_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_tmp_fields", force: true do |t|
    t.integer  "model_id"
    t.string   "schema"
    t.string   "tablename"
    t.string   "field"
    t.string   "data_type"
    t.string   "accessor"
    t.string   "default_value"
    t.string   "default_data_format"
    t.string   "default_data_format_edit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_tmp_layouts", force: true do |t|
    t.integer  "page_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_tmp_model_display_formats", force: true do |t|
    t.string   "name"
    t.string   "app_wrapper"
    t.string   "app_wrapper_end"
    t.string   "field_header_wrapper"
    t.string   "field_header_wrapper_end"
    t.string   "record_wrapper"
    t.string   "record_wrapper_end"
    t.string   "field_wrapper"
    t.string   "field_wrapper_end"
    t.string   "separate_header_row"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_tmp_model_displays", force: true do |t|
    t.integer  "block_id"
    t.integer  "model_id"
    t.string   "format"
    t.string   "action"
    t.string   "header"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_tmp_models", force: true do |t|
    t.string   "modyule"
    t.string   "classname"
    t.string   "schema"
    t.string   "tablename"
    t.string   "name"
    t.string   "default_sort_field"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_tmp_options", force: true do |t|
    t.integer  "field_id"
    t.string   "text"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_tmp_pages", force: true do |t|
    t.string   "name"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_tmp_records_formats", force: true do |t|
    t.string   "name"
    t.string   "classname"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_tmp_selects", force: true do |t|
    t.integer  "field_display_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_tmp_textboxes", force: true do |t|
    t.integer  "field_display_id"
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_bar_tmp_textreads", force: true do |t|
    t.integer  "field_display_id"
    t.integer  "truncation"
    t.text     "truncation_format"
    t.text     "transformation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
