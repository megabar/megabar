module MegaBar
  module PageProcessing
    def render_megabar_page(env)
      orig_query_hash = Rack::Utils.parse_nested_query(env["QUERY_STRING"])
      final_layouts = process_layouts(env, orig_query_hash)
      
      env["mega_final_layouts"] = final_layouts
      @status, @headers, @page = MegaBar::MasterPagesController.action(:render_page).call(env)
      
      final_page_content = @page.blank? ? "" : @page.body.html_safe
      final_page = [final_page_content]
      
      @redirect ? [@redirect[0], @redirect[1], ["you are being redirected"]] : [@status, @headers, final_page]
    end

    def process_layouts(env, orig_query_hash)
      page_layouts = MegaBar::Layout.by_page(env[:mega_page][:page_id]).includes(:sites, :themes)
      final_layouts = []
      
      page_layouts.each do |page_layout|
        next if mega_filtered(page_layout, env[:mega_site])
        
        env[:mega_layout] = page_layout
        final_layout_sections = process_page_layout(page_layout, env[:mega_page], env[:mega_rout], orig_query_hash, env[:mega_pagination], env[:mega_site], env)
        
        env["mega_final_layout_sections"] = final_layout_sections
        @status, @headers, @layouts = MegaBar::MasterLayoutsController.action(:render_layout_with_sections).call(env)
        final_layouts << (@layouts.blank? ? "" : @layouts.body.html_safe)
      end
      
      final_layouts
    end

    def process_page_layout(page_layout, page_info, rout, orig_query_hash, pagination, site, env)
      final_layout_sections = {}
      
      page_layout.layout_sections.each do |layout_section|
        process_layout_section(layout_section, page_layout, page_info, rout, orig_query_hash, pagination, site, env, final_layout_sections)
      end
      
      final_layout_sections
    end

    def process_layout_section(layout_section, page_layout, page_info, rout, orig_query_hash, pagination, site, env, final_layout_sections)
      template_section = get_template_section(layout_section, page_layout)
      blocks = get_filtered_blocks(layout_section, rout, page_info)
      return unless blocks.present?

      final_layout_sections[template_section] = []
      env[:mega_layout_section] = layout_section
      
      process_blocks(blocks, page_info, rout, orig_query_hash, pagination, site, env, final_layout_sections, template_section)
    end

    def get_template_section(layout_section, page_layout)
      MegaBar::TemplateSection.find(
        layout_section.layables.where(layout_id: page_layout.id).first.template_section_id
      ).code_name
    end
  end
end 