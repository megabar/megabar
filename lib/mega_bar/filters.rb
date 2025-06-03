module MegaBar
  class PathMatcher
    def initialize(blocks, request_uri)
      @blocks = blocks.respond_to?(:each) ? blocks : [blocks]
      @request_terms = extract_terms(request_uri)
    end

    def find_best_match
      best_matches = find_best_matches
      best_matches.first
    end

    def find_best_matches
      return [] if @request_terms.blank?
      
      best_score = Float::INFINITY
      best_matches = []

      @blocks.each do |block|
        block_terms = extract_path_terms(block.path_base)
        next unless compatible_path?(@request_terms, block_terms)
        next if home_page_mismatch?(block_terms, @request_terms)

        score = calculate_difference(@request_terms, block_terms)
        
        if score < best_score
          best_score = score
          best_matches = [block]
        elsif score == best_score
          best_matches << block
        end
      end

      best_matches
    end

    private

    def extract_terms(uri)
      uri.to_s.split("/").reject { |c| c.nil? || c.empty? }
    end

    def extract_path_terms(path)
      return [] if path.blank?
      path.split("/").map { |m| m if m[0] != ":" } - ["", nil]
    end

    def compatible_path?(request_terms, block_terms)
      (request_terms - block_terms).size == request_terms.size - block_terms.size
    end

    def home_page_mismatch?(block_terms, request_terms)
      block_terms.empty? && !request_terms.empty?
    end

    def calculate_difference(request_terms, block_terms)
      (request_terms - block_terms).size
    end
  end

  class ChosenFieldFilter
    def initialize(blocks, page_info)
      @blocks = blocks
      @page_info = page_info
    end

    def filter
      return @blocks.none if @page_info[:terms].blank?

      model = find_model
      return @blocks.none unless model

      chosen_block_ids = extract_chosen_block_ids(model)
      @blocks.where(id: chosen_block_ids)
    end

    private

    def find_model
      classname = @page_info[:terms][0].classify
      MegaBar::Model.where(classname: classname).first
    end

    def extract_chosen_block_ids(model)
      chosen_fields = model.fields.where("field LIKE ?", LayoutEngine::TEMPLATE_FIELD_PATTERN).pluck(:field)
      
      object_id = @page_info[:vars][0].to_i
      chosen_obj = @page_info[:terms][0].classify.constantize.find(object_id)
      
      chosen_fields.filter_map { |field| chosen_obj.send(field) if chosen_obj.respond_to?(field) }
    end
  end

  class SiteFilter
    def initialize(obj, site)
      @obj = obj
      @site = site
    end

    def filtered?
      site_filtered? || theme_filtered?
    end

    private

    def site_filtered?
      return false unless @obj.respond_to?(:sites) && @obj.sites.present?
      
      site_ids = @obj.sites.pluck(:id)
      has_zero_site = site_ids.include?(0)
      has_current_site = site_ids.include?(@site.id)
      
      (has_zero_site && has_current_site) || !has_current_site
    end

    def theme_filtered?
      return false unless @obj.respond_to?(:themes) && @obj.themes.present?
      
      theme_ids = @obj.themes.pluck(:id)
      has_zero_theme = theme_ids.include?(0)
      has_current_theme = theme_ids.include?(@site.theme_id)
      
      (has_zero_theme && has_current_theme) || !has_current_theme
    end
  end
end 