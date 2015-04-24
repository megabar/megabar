module MegaBar
  class Page < ActiveRecord::Base
    has_many :layouts, dependent: :destroy
    scope :by_route, ->(route) { where(path: route) if route.present? }
    attr_accessor :make_layout_and_block, :block_text, :model_id, :base_name
    after_create :create_layout_for_page
    after_create :add_route
    validates_presence_of :path, :name

    def create_layout_for_page
      base_name = (self.base_name.nil? || self.base_name.empty?) ? self.name : self.base_name
      layout_hash = {page_id: self.id, name: base_name.humanize + ' Layout', base_name: base_name, make_block: true, model_id: self.model_id}
      layout_hash = layout_hash.merge({block_text: self.block_text}) if self.block_text
      _layout = Layout.create(layout_hash)  if (!Layout.by_page(self.id).present? && @make_layout_and_block == 'y')
    end

    def add_route
      gem_path = ''
      line = '  ##### MEGABAR END'
      text = File.read(gem_path + 'config/routes.rb')
      if self.model_id
        mod = Model.find(self.model_id)
        gem_path = Rails.root + '../megabar/'  if File.directory?(Rails.root + '../megabar/')  && mod.modyule == 'MegaBar'
        route_text = ' resources :' + mod.classname.downcase.pluralize
        route_text += ", path: '#{self.path}'" if '/' + mod.tablename != self.path
        route_text += "\n #{line}"
      else
        route_text = "get '#{self.path}', to: 'flats#index'"
        route_text += "\n #{line}"
      end
      new_contents = text.gsub( /(#{Regexp.escape(line)})/mi, route_text)
      # To write changes to the file, use:
      File.open(gem_path + 'config/routes.rb', "w") {|file| file.puts new_contents } # unless gem_path == '' && mod.modyule == 'MegaBar'
      # @@notices <<  "You will have to add the route yourself manually to the megabar route file: #{route_text}" if gem_path == '' && modyule == 'MegaBar'
    end


  end
end
