module MegaBar
  module BlockProcessing
    def get_filtered_blocks(layout_section, rout, page_info)
      MegaBar::BlockFilter.new(layout_section, rout, page_info).filter
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
      mega_env = MegaBar::MegaEnv.new(blck, rout, page_info, pagination, @user)
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