module MegaBar 
  class LayoutSectionsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    
    def get_options
 

      @options[:mega_bar_layout_sections] =  {
        layout_ids: Layout.all.order('name asc').pluck("name, id"),
        template_section_id: TemplateSection.includes(:template).all.order('mega_bar_templates.id asc, mega_bar_template_sections.id asc').map{|ts| ["template #{ts.template_id} - #{ts.template.name} - #{ts.name}", ts.id] }
      }
    end

  end
end 
