module MegaBar
  class GridHtml
    attr_accessor :app_format
    attr_accessor :app_wrapper
    attr_accessor :field_header_wrapper
    attr_accessor :app_wrapper_end
    attr_accessor :field_header_wrapper
    attr_accessor :field_header_wrapper_end
    attr_accessor :record_wrapper
    attr_accessor :record_wrapper_end
    attr_accessor :field_wrapper
    attr_accessor :field_wrapper_end 
    attr_accessor :separate_header_row
    def initialize
      @app_format = 'grid'
      @app_wrapper = '<table>'
      @app_wrapper_end = '</table>'
      @field_header_wrapper = '<th>'
      @field_header_wrapper_end =  '</th>'
      @record_wrapper = '<tr>'
      @record_wrapper_end = '<th>'
      @field_wrapper = '<td>'
      @field_wrapper_end = '</td>'
      @separate_header_row = true
    end
  end
end