module MegaBar
  class LayoutRenderer
    def initialize(context, orig_query_hash)
      @context = context
      @orig_query_hash = orig_query_hash
    end

    def render
      page_layouts = load_page_layouts
      rendered_layouts = []

      page_layouts.each do |page_layout|
        next if filtered_out?(page_layout)
        
        @context.env[:mega_layout] = page_layout
        layout_sections = process_layout_sections(page_layout)
        
        rendered_layout = render_layout_with_sections(layout_sections)
        rendered_layouts << rendered_layout
      end

      rendered_layouts
    end

    private

    def load_page_layouts
      MegaBar::Layout.by_page(@context.page_info[:page_id])
                     .includes(:sites, :themes)
    end

    def filtered_out?(page_layout)
      SiteFilter.new(page_layout, @context.site).filtered?
    end

    def process_layout_sections(page_layout)
      LayoutSectionProcessor.new(page_layout, @context, @orig_query_hash).process
    end

    def render_layout_with_sections(layout_sections)
      # Get the actual page object if we have a page_id
      mega_page = nil
      if @context.page_info[:page_id]
        mega_page = MegaBar::Page.find_by(id: @context.page_info[:page_id])
        # Ensure page attributes are safe for string operations
        if mega_page
          mega_page.name = mega_page.name || "Home"
          mega_page.path = mega_page.path || "/"
        end
      end
      
      # Ensure essential data is available in env for controllers
      @context.env[:mega_page_info] = @context.page_info
      @context.env[:mega_page_object] = mega_page  # Store the actual page object separately
      @context.env[:mega_rout] = @context.route_info
      @context.env[:mega_user] = @context.user
      @context.env[:mega_site] = @context.site
      @context.env["mega_final_layout_sections"] = layout_sections
      
      status, headers, layouts = MegaBar::MasterLayoutsController
                                  .action(:render_layout_with_sections)
                                  .call(@context.env)
      
      layouts.blank? ? "" : layouts.body.html_safe
    end
  end

  class LayoutSectionProcessor
    def initialize(page_layout, context, orig_query_hash)
      @page_layout = page_layout
      @context = context
      @orig_query_hash = orig_query_hash
    end

    def process
      final_layout_sections = {}
      puts "🔍 Layout has #{@page_layout.layout_sections.count} sections to process"

      @page_layout.layout_sections.each do |layout_section|
        puts "🔍 Processing layout_section #{layout_section.id}"
        begin
          template_section = find_template_section(layout_section)
          puts "🔍 Found template_section: #{template_section}"
          
          blocks = load_and_filter_blocks(layout_section)
          
          if !blocks.present?
            puts "🚫 Skipping layout_section #{layout_section.id} - no blocks after filtering"
            next
          end

          rendered_section = process_section_blocks(layout_section, blocks)
          final_layout_sections[template_section] = [rendered_section]
          puts "✅ Successfully processed layout_section #{layout_section.id}"
        rescue => e
          Rails.logger.error "Error processing layout section #{layout_section.id}: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          puts "❌ Error in layout_section #{layout_section.id}: #{e.message}"
          puts "❌ Backtrace: #{e.backtrace.first(3).join(' | ')}"
          next
        end
      end

      puts "🔍 Final layout sections: #{final_layout_sections.keys}"
      final_layout_sections
    end

    private

    def find_template_section(layout_section)
      # Add caching for expensive lookup
      Rails.cache.fetch("template_section_#{layout_section.id}_#{@page_layout.id}", expires_in: 1.hour) do
        MegaBar::TemplateSection.find(
          layout_section.layables.where(layout_id: @page_layout.id).first.template_section_id
        ).code_name
      end
    end

    def load_and_filter_blocks(layout_section)
      byebug
      blocks = MegaBar::Block.by_layout_section(layout_section.id).order(position: :asc)
      
      # Debug: let's see what action we're filtering by
      puts "🔍 Filtering blocks by action: '#{@context.route_info[:action]}' for layout_section #{layout_section.id}"
      puts "🔍 Total blocks before filtering: #{blocks.count}"
      
      blocks = blocks.by_actions(@context.route_info[:action]) unless @context.route_info.blank?
      
      puts "🔍 Blocks after action filtering: #{blocks.count}"
      blocks.each { |b| puts "  Block #{b.id}: actions='#{b.actions}'" }

      # Apply rule-based filtering
      case layout_section.rules
      when LayoutEngine::LayoutRules::SPECIFIC
        PathMatcher.new(blocks, @context.env["REQUEST_URI"]).find_best_matches
      when LayoutEngine::LayoutRules::CHOSEN
        ChosenFieldFilter.new(blocks, @context.page_info).filter
      else
        blocks
      end
    end

    def process_section_blocks(layout_section, blocks)
      byebug
      @context.env[:mega_layout_section] = layout_section
      
      final_blocks = BlockProcessor.new(blocks, @context, @orig_query_hash).process
      @context.env["mega_final_blocks"] = final_blocks

      status, headers, layout_sections = MegaBar::MasterLayoutSectionsController
                                         .action(:render_layout_section_with_blocks)
                                         .call(@context.env)
      
      layout_sections.blank? ? "" : layout_sections.body.html_safe
    end
  end

  class BlockProcessor
    def initialize(blocks, context, orig_query_hash)
      @blocks = blocks
      @context = context
      @orig_query_hash = orig_query_hash
    end

    def process
      @blocks.filter_map do |block|
        next if filtered_out?(block)
        build_block_info(block)
      end
    end

    private

    def filtered_out?(block)
      SiteFilter.new(block, @context.site).filtered?
    end

    def build_block_info(block)
      {
        id: block.id,
        header: extract_header(block),
        actions: block.actions,
        action: @context.route_info[:action],
        html: render_block_html(block)
      }
    end

    def extract_header(block)
      block.model_displays.where(action: "index").first&.header
    end

    def render_block_html(block)
      BlockRenderer.new(block, @context, @orig_query_hash).render
    end
  end

  class BlockRenderer
    def initialize(block, context, orig_query_hash)
      @block = block
      @context = context
      @orig_query_hash = orig_query_hash
    end

    def render
      byebug
      return @block.html.html_safe if static_html_block?
      return "" if empty_model_displays?
      
      render_dynamic_block
    end

    private

    def static_html_block?
      @block.html.present?
    end

    def empty_model_displays?
      @block.model_displays.empty?
    end

    def render_dynamic_block
      mega_env = build_mega_env
      params_hash = build_params_hash(mega_env)
      
      setup_environment(mega_env, params_hash)
      
      status, headers, disp_body = execute_controller_action(mega_env)
      handle_controller_response(status, headers, disp_body)
    end

    def build_mega_env
      MegaEnv.new(@block, @context.route_info, @context.page_info, @context.pagination, @context.user)
    end

    def build_params_hash(mega_env)
      params_hash = {}
      
      # Collect all parameter components
      params_components = mega_env.params_hash_arr.dup
      params_components << { action: mega_env.block_action }
      params_components << { controller: mega_env.kontroller_path }
      
      # Merge all components
      params_components.each { |component| params_hash.merge!(component) }
      params_hash.merge!(@orig_query_hash)
      
      # Add form data if present
      if @context.env["rack.request.form_hash"]
        params_hash.merge!(@context.env["rack.request.form_hash"])
      end
      
      params_hash
    end

    def setup_environment(mega_env, params_hash)
      @context.env[:mega_env] = mega_env.to_hash
      @context.env[:mega_page] = @context.page_info  # Controllers expect this
      @context.env[:mega_rout] = @context.route_info  # Controllers expect 'mega_rout' not 'mega_route_info'
      @context.env[:mega_layout] = @context.env[:mega_layout]  # Pass through layout
      @context.env["QUERY_STRING"] = params_hash.to_param
      @context.env["action_dispatch.request.parameters"] = params_hash
      @context.env["block_classes"] = build_block_classes
    end

    def build_block_classes
      classes = []
      classes << @block.name.downcase.parameterize.underscore
      classes << "active" if first_tab?
      classes
    end

    def first_tab?
      return false unless @context.env[:mega_layout_section]&.rules == LayoutEngine::LayoutRules::TABS
      
      first_show_block = MegaBar::Block.by_layout_section(@block.layout_section_id)
                                      .where(actions: "show")
                                      .first
      
      @block.id == first_show_block&.id
    end

    def execute_controller_action(mega_env)
      controller_class = mega_env.kontroller_klass.constantize
      controller_class.action(mega_env.block_action).call(@context.env)
    rescue => e
      Rails.logger.error "Error executing controller action: #{e.message}"
      [500, {}, StringIO.new("Error rendering block")]
    end

    def handle_controller_response(status, headers, disp_body)
      # Handle redirects in the parent context
      if status == LayoutEngine::HTTP_REDIRECT
        @context.instance_variable_set(:@redirect, [status, headers, disp_body])
      end
      
      # Handle different response body types
      if disp_body.blank?
        ""
      elsif disp_body.respond_to?(:body)
        disp_body.body.html_safe
      elsif disp_body.respond_to?(:read)
        # Handle StringIO and similar objects
        disp_body.read.html_safe
      else
        disp_body.to_s.html_safe
      end
    end
  end
end 