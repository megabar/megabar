module MegaBar
  class LayablesController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern

    def index
      if @layout
        @layables = Layable.where(layout_id: @layout.id)
        @bob = display_layout
        render plain: @bob
      else
        super
      end
    end

    def display_layout
      final_layout_sections = {}
      @layout.template.template_sections.each do |section|
        @layable = @layables.find_by(template_section_id: section.id)
        final_layout_sections[section.code_name] = []
        final_layout_sections[section.code_name][0] = generate_section(section)
      end
      
      # Build the layout HTML manually
      html = []
      html << "<div class='layout-settings'>"
      final_layout_sections.each do |section_name, content|
        html << "<div class='section #{section_name}'>"
        html << content[0]
        html << "</div>"
      end
      html << "</div>"
      
      html.join("\n")
    end

    def generate_section(template_section)
      m_layout_section = MegaBar::MasterLayoutSectionsController.new
      m_layout_section.request = request
      m_layout_section.response = response
      m_layout_section.instance_variable_set('@layable', @layable)
      m_layout_section.instance_variable_set('@mega_layout_section', template_section)
      m_layout_section.instance_variable_set('@mega_layout', @layout)
      
      # Get the blocks for this section
      blocks = MegaBar::Block.by_layout_section(template_section.id).order(position: :asc)
      m_layout_section.instance_variable_set('@blocks', blocks.map do |blck|
        {
          id: blck.id,
          header: blck.model_displays.where(action: 'index').first&.header,
          actions: blck.actions,
          html: blck.html || ''
        }
      end)
      byebug
      # Render the section template
      m_layout_section.render_to_string('render_layout_section_admin')
    end
  end
end
