module MegaBar
  class PageProcessor
    def initialize(app = nil)
      @app = app
      @redirect = false
    end

    def process(env, page_info)
      orig_query_hash = Rack::Utils.parse_nested_query(env["QUERY_STRING"])
      final_layouts = []

      page_layouts = MegaBar::Layout.by_page(page_info[:page_id]).includes(:sites, :themes)
      page_layouts.each do |page_layout|
        next if mega_filtered(page_layout, env[:mega_site])
        
        env[:mega_layout] = page_layout
        final_layout_sections = process_page_layout(page_layout, page_info, env[:mega_rout], orig_query_hash, env[:mega_pagination], env[:mega_site], env)

        env["mega_final_layout_sections"] = final_layout_sections
        @status, @headers, @layouts = MegaBar::MasterLayoutsController.action(:render_layout_with_sections).call(env)
        final_layouts << (l = @layouts.blank? ? "" : @layouts.body.html_safe)
      end

      env["mega_final_layouts"] = final_layouts
      @status, @headers, @page = MegaBar::MasterPagesController.action(:render_page).call(env)
      
      final_page = []
      final_page_content = @page.blank? ? "" : @page.body.html_safe
      final_page << final_page_content
      
      @redirect ? [@redirect[0], @redirect[1], ["you are being redirected"]] : [@status, @headers, final_page]
    end

    private

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

    def get_filtered_blocks(layout_section, rout, page_info)
      blocks = MegaBar::Block.by_layout_section(layout_section.id).order(position: :asc)
      blocks = blocks.by_actions(rout[:action]) unless rout.blank?
      
      case layout_section.rules
      when "specific"
        filter_specific_blocks(blocks, page_info)
      when "chosen"
        filter_chosen_blocks(blocks, page_info)
      else
        blocks
      end
    end

    def filter_specific_blocks(blocks, page_info)
      rout_terms = page_info[:page_path].split("/").reject! { |c| (c.nil? || c.empty?) }
      best_block = find_best_matching_block(blocks, rout_terms)
      blocks.reject { |b| b.id != best_block.id }
    end

    def find_best_matching_block(blocks, rout_terms)
      diff = 20
      prev_diff = 21
      best = nil

      blocks.each do |block|
        page_path_terms = block.path_base.split("/").map { |m| m if m[0] != ":" } - ["", nil]
        next if (rout_terms - page_path_terms).size != rout_terms.size - page_path_terms.size
        next if (page_path_terms.empty? && !rout_terms.empty?)

        current_diff = (rout_terms - page_path_terms).size
        if current_diff < prev_diff
          best = block
          prev_diff = current_diff
        end
      end

      best
    end

    def filter_chosen_blocks(blocks, page_info)
      model = MegaBar::Model.where(classname: page_info[:terms][0].classify).first
      chosen_fields = model.fields.where("field LIKE ?", "%template%").pluck(:field)
      chosen_obj = page_info[:terms][0].classify.constantize.find(page_info[:vars][0].to_i)
      chosen_blocks = chosen_fields.map { |f| chosen_obj.send(f) }
      blocks.where(id: chosen_blocks)
    end

    def process_blocks(blocks, page_info, rout, orig_query_hash, pagination, site, env, final_layout_sections, template_section)
      final_blocks = blocks.map do |blck|
        next if mega_filtered(blck, site)
        build_block_info(blck, page_info, rout, orig_query_hash, pagination, env)
      end.compact

      env["mega_final_blocks"] = final_blocks
      render_layout_section(env, final_layout_sections, template_section)
    end

    def build_block_info(blck, page_info, rout, orig_query_hash, pagination, env)
      {
        id: blck.id,
        header: blck.model_displays.where(action: "index").first&.header,
        actions: blck.actions,
        action: rout[:action],
        html: process_block(blck, page_info, rout, orig_query_hash, pagination, env)
      }
    end

    def render_layout_section(env, final_layout_sections, template_section)
      @status, @headers, @layout_sections = MegaBar::MasterLayoutSectionsController
        .action(:render_layout_section_with_blocks)
        .call(env)
      
      final_layout_sections[template_section] << (
        @layout_sections.blank? ? "" : @layout_sections.body.html_safe
      )
    end

    def process_block(blck, page_info, rout, orig_query_hash, pagination, env)
      return render_html_block(blck) if has_html_content?(blck)
      return "" if blck.model_displays.empty?
      
      process_model_display_block(blck, page_info, rout, orig_query_hash, pagination, env)
    end

    def has_html_content?(blck)
      blck.html.present? && !blck.html.empty?
    end

    def render_html_block(blck)
      blck.html.html_safe
    end

    def process_model_display_block(blck, page_info, rout, orig_query_hash, pagination, env)
      mega_env = MegaBar::MegaEnv.new(blck, rout, page_info, pagination, env[:mega_user])
      setup_environment(mega_env, orig_query_hash, env)
      render_block_content(mega_env, blck, env)
    end

    def setup_environment(mega_env, orig_query_hash, env)
      params_hash = build_params_hash(mega_env, orig_query_hash, env)
      env[:mega_env] = mega_env.to_hash
      env["QUERY_STRING"] = params_hash.to_param
      env["action_dispatch.request.parameters"] = params_hash
      setup_block_classes(env, mega_env.block)
    end

    def build_params_hash(mega_env, orig_query_hash, env)
      params_hash = {}
      params_hash_arr = mega_env.params_hash_arr + [
        { action: mega_env.block_action },
        { controller: mega_env.kontroller_path }
      ]
      
      params_hash_arr.each { |param| params_hash.merge!(param) }
      params_hash.merge!(orig_query_hash)
      params_hash.merge!(env["rack.request.form_hash"]) if env["rack.request.form_hash"].present?
      
      params_hash
    end

    def setup_block_classes(env, blck)
      env["block_classes"] = [
        blck.name.downcase.parameterize.underscore,
        ("active" if first_tab(env, blck))
      ].compact
    end

    def render_block_content(mega_env, blck, env)
      @status, @headers, @disp_body = mega_env.kontroller_klass.constantize
        .action(mega_env.block_action)
        .call(env)
      
      @redirect = [@status, @headers, @disp_body] if @status == 302
      @disp_body.blank? ? "" : @disp_body.body.html_safe
    end

    def first_tab(env, blck)
      return false if env[:mega_layout_section]&.rules != "tabs"

      blck.id == MegaBar::Block.by_layout_section(blck.layout_section_id).where(actions: "show").first&.id
    end

    def mega_filtered(obj, site)
      if obj.sites.present?
        has_zero_site = obj.sites.pluck(:id).include?(0)
        has_site = obj.sites.pluck(:id).include?(site.id)
        return true if has_zero_site and has_site
        return true if !has_site
      end
      if obj.themes.present?
        has_zero_theme = obj.themes.pluck(:id).include?(0)
        has_theme = obj.themes.pluck(:id).include?(site.theme_id)
        return true if has_zero_theme and has_theme
        return true if !has_theme
      end
      false
    end
  end
end 