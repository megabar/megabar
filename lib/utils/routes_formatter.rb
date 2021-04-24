module ActionDispatch
  module Routing
    class MarkdownFormatter
      def initialize(path=nil)
        @buffer = []
        @path = path
      end

      def result
        @buffer.join("\n")
        @buffer.reject(&:empty?)
      end

      def section_title(title)
        @buffer << ""
      end

      def section(routes)
        @buffer << draw_section(routes)
      end

      def header(routes)
        @buffer << draw_header(routes)
      end

      def no_routes
        @buffer << <<~MESSAGE
          You don't have any routes defined!
          Please add some routes in config/routes.rb.
          For more information about routes, see the Rails guide: http://guides.rubyonrails.org/routing.html.
        MESSAGE
      end

      private

      def draw_section(routes)
        routes = routes.select{|r|  r[:path].include? @path } unless @path.nil?
        routes.map do |r|
          " name: #{r[:name]}\n        verb: #{r[:verb]}\n        path: #{r[:path]}\n  controller: #{r[:reqs]}\n       regex: #{r[:regexp]} \n------------------------------------------------------------------------\n"
        end
      end

      def draw_header(routes)
        str = "\n\n"
        str += @path.present? ? "HERE ARE THE ROUTES FILTERED BY #{@path}" : "HERE ARE ALL THE ROUTES"
        str += "\n========================================================================\n\n"
      end
    end
  end
end
