module MegaBar
  class Page < ActiveRecord::Base
    has_many :layouts, dependent: :destroy
    scope :by_route, ->(route) { where(path: route) if route.present? }
    attr_accessor :make_layout_and_block, :block_text, :model_id, :base_name, :template_id
    after_create :create_layout_for_page
    after_create :add_route
    validates_presence_of :path, :name
    validates_uniqueness_of :path

    def create_layout_for_page
      base_name = (self.base_name.nil? || self.base_name.empty?) ? self.name : self.base_name
      template_id = self.template_id.present? ? self.template_id : self.make_layout_and_block
      layout_hash = {page_id: self.id, name: base_name.humanize + ' Layout', base_name: base_name, make_block: true, model_id: self.model_id, template_id: template_id}
      layout_hash = layout_hash.merge({block_text: self.block_text}) if self.block_text
# byebug
      _layout = Layout.create(layout_hash)  if (!Layout.by_page(self.id).present? && template_id.present?)
    end

    def add_route
      return if ENV['RAILS_ENV'] == 'test'
      Rails.application.reload_routes! 
      # this now just adds it to the spec_helper.
      gem_path = ''
      # line = '  ##### MEGABAR END'
      # text = File.read('spec/spec_helper.rb')
      # if self.model_id
      #   mod = Model.find(self.model_id)
      #   gem_path = Rails.root + '../megabar/'  if File.directory?(Rails.root + '../megabar/')  && mod.modyule == 'MegaBar'
      #   route_text = ' resources :' + mod.classname.downcase.pluralize
      #   route_text += ", path: '#{self.path}'" if '/' + mod.tablename != self.path
      #   route_text += "\n #{line}"
      # else
      #   route_text = "get '#{self.path}', to: 'flats#index'"
      #   route_text += "\n #{line}"
      # end
      # new_contents = text.gsub( /(#{Regexp.escape(line)})/mi, route_text)
      # # To write changes to the file, use:
      # File.open(gem_path + 'spec/spec_helper.rb', "w") {|file| file.puts new_contents } # unless gem_path == '' && mod.modyule == 'MegaBar'
      # @@notices <<  "You will have to add the route yourself manually to the megabar route file: #{route_text}" if gem_path == '' && modyule == 'MegaBar'
    end


  end
end
