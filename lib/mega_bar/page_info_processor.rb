module MegaBar
  class PageInfoProcessor
    def initialize(rout, rout_terms)
      @rout = rout
      @rout_terms = rout_terms || []
      @prev_diff = Float::INFINITY
    end

    def process
      page_info = {}
      
      MegaBar::Page.all.order(id: :desc).pluck(:id, :path, :name, :administrator).each do |page|
        next unless page_matches_rout_terms?(page[1])
        
        page_terms = page[1].split("/").reject! { |c| (c.nil? || c.empty?) } || []
        variable_segments = extract_variable_segments(page_terms)
        
        current_diff = calculate_path_difference(page_terms)
        if current_diff < @prev_diff
          page_info = build_page_info(page, page_terms, variable_segments)
          @prev_diff = current_diff
        end
      end
      
      page_info
    end

    private

    def page_matches_rout_terms?(page_path)
      page_path_terms = page_path.split("/").map { |m| m if m[0] != ":" } - ["", nil]
      return false if (@rout_terms - page_path_terms).size != @rout_terms.size - page_path_terms.size
      return false if (page_path_terms.empty? && !@rout_terms.empty?)
      true
    end

    def extract_variable_segments(page_terms)
      segments = []
      page_terms.each_with_index do |term, index|
        segments << @rout_terms[index] if term.starts_with?(":")
      end
      
      begin
        if @rout_terms[page_terms.size] && Integer(@rout_terms[page_terms.size])
          segments << @rout_terms[page_terms.size]
        end
      rescue ArgumentError
        # Not a valid integer, skip it
      end
      
      segments
    end

    def calculate_path_difference(page_terms)
      (@rout_terms - page_terms).size
    end

    def build_page_info(page, page_terms, variable_segments)
      {
        page_id: page[0],
        page_path: page[1],
        terms: page_terms,
        vars: variable_segments,
        name: page[2],
        administrator: page[3]
      }
    end
  end
end 