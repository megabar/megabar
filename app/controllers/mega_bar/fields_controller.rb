module MegaBar
  class FieldsController < ApplicationController
    include MegaBarConcern

    def new
      @default_options[:model_id] = @nested_instance_variables[0]&.id
      @default_options[:tablename] = @nested_instance_variables[0]&.tablename
      super
    end

    def get_options
      blocks = []
      # bad news, if the block doesn't have model_displays it doesnt show up in this menu
      ModelDisplay.select(:block_id).distinct.pluck("block_id, model_id").each do |md|
        blocks << ['id: ' + md[0].to_s + ', model: ' + Model.find(md[1]).name + ' (' + md[1].to_s + '), ' + Block.find(md[0]).name, md[0]]
      end
      # md_ids = {model_display_ids: ModelDisplay.by_model(env[:mega_env][:nested_ids][0]["model_id"])} unless env[:mega_env][:nested_ids].blank
      @options[:mega_bar_fields] =  {
        model_id: Model.all.pluck("name, id"),
        tablename: Model.all.pluck("tablename, tablename"),
        block_id: blocks

      }
      unless env[:mega_env][:nested_ids].blank?
        md_opts = []
        ModelDisplay.by_model(env[:mega_env][:nested_ids][0]["model_id"]).each do | m|
          md_opts << [m[:id].to_s + ": " + m[:header], m[:id]]
        end
        @options[:mega_bar_fields][:model_display_ids] =  md_opts
      end
    end
  end
end
