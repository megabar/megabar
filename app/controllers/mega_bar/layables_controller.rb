module MegaBar
  class LayablesController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern    

    def index
      if @layout
        @layables = Layable.where(layout_id: @layout.id)
        # @template = Template.find(@layout.template_id)
        @bob = display_layout
        render
      else 
        super
      end
    end
    
    def display_layout
      m_layout = MegaBar::MasterLayoutsController.new
      m_layout.request = request
      m_layout.response = response
      final_layout_sections = {}
      @layout.template.template_sections.each do |section|
        @layable = @layables.find_by(template_section_id: section.id)
        final_layout_sections[section.code_name] = []
        final_layout_sections[section.code_name][0] = generate_section(section)
     end
      m_layout.instance_variable_set('@mega_layout_sections', final_layout_sections)
      m_layout.instance_variable_set('@mega_layout', @layout)
      # m_layout.instance_variable_set('@layout_helper', true)
      # env['mega_final_layout_sections'] = final_layout_sections #used in master_layouts_controller
      m_layout.render_layout_with_sections
    end
    
    def generate_section(template_section)
      m_layout_section = MegaBar::MasterLayoutSectionsController.new
      m_layout_section.request = request
      m_layout_section.response = response  
      m_layout_section.instance_variable_set('@layable', @layable)
      html = m_layout_section.render_layout_section_admin
      html[0]
      # matches = Gem::Specification.find_all_by_name 'mega_bar'
      # mega = matches.first
      # filename = File.expand_path('app/views/mega_bar/layables/section.html.erb', mega.full_gem_path)
      # template = File.read(filename)
      # final_section = ERB.new(template).result( binding )

      # "I am #{section.code_name}"
    end
  end
end 
