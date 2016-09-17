module MegaBar 
  class TemplateSectionsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern

    def new
      @template_id = params["template_id"] if params["template_id"]
      super
    end
    def get_options
      @options[:mega_bar_template_sections] =  {
        template_id: Template.all.pluck("name, id")
      }
    end

  end
end 
