module MegaBar
  class TemplatesController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern

    def render_template_with_layout_sections
      # @blocks = env["mega_final_blocks"]
      # @mega_layout_section = env[:mega_layout_section]
      # @mega_page = env[:mega_page]

      # @tabs = @blocks.select { |blck| blck[:actions] == "show" }

      # bob = render_to_string("mega_bar/master_layouts/#{@layout.template.code_name}")

      bob = render_to_string template: "mega_bar/master_layouts/#{@mega_layout.template.code_name}"
      bob
    end
  end
end
