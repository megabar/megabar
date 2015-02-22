module MegaBar
  class FieldsController < ApplicationController
    include MegaBarConcern

    def get_options
      blocks = []
      ModelDisplay.select(:block_id).distinct.pluck("block_id, model_id").each do |md| 
        blocks << ['id: ' + md[0].to_s + ', model: ' + Model.find(md[1]).name + ' (' + md[1].to_s + '), ' + Block.find(md[0]).name, md[0]]
      end
      @options[:mega_bar_fields] =  {
        model_id: Model.all.pluck("name, id"), 
        tablename: Model.all.pluck("tablename, tablename"), 
        block_id: blocks
      }
    end
  end
end
