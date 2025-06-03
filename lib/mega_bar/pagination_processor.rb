module MegaBar
  class PaginationProcessor
    def initialize(env, rout_terms)
      @env = env
      @rout_terms = rout_terms
    end

    def process
      pagination_info = []
      pagination_info.concat(extract_from_rout_terms)
      pagination_info.concat(extract_from_query_string)
      pagination_info
    end

    private

    def extract_from_rout_terms
      return [] unless @rout_terms.present?
      
      @rout_terms.map.with_index do |term, index|
        next unless term.match?(/_page$/)
        { kontrlr: term, page: @rout_terms[index + 1] }
      end.compact
    end

    def extract_from_query_string
      query_hash = Rack::Utils.parse_nested_query(@env["QUERY_STRING"])
      query_hash.map do |key, value|
        next unless key.match?(/_page$/)
        { kontrlr: key, page: value }
      end.compact
    end
  end
end 