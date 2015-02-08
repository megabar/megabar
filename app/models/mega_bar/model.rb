module MegaBar
  class Model < ActiveRecord::Base
    self.table_name = "mega_bar_models"
    include MegaBar::MegaBarModelConcern
    validates_presence_of :classname
    validates_presence_of :default_sort_field
   # validates_format_of :classname, on: [:create, :update], :multiline => true, allow_nil: false, with: /([A-Z][a-z])\w+/
 
    has_many :fields, dependent: :destroy
    has_many :model_displays, dependent: :destroy
    before_create :standardize_module
    before_create :standardize_classname
    before_create :standardize_tablename

    after_create  :make_model_displays
    after_create :make_all_files
    after_save :make_model_displays
    #has_many :attributes #ack you can't do this!  http://reservedwords.herokuapp.com/words/attributes
    attr_accessor :model_id, :new_model_display, :edit_model_display, :index_model_display, :show_model_display
    attr_writer :model_id

    scope :by_model, ->(model_id) { where(id: model_id) if model_id.present? }

    private

    def make_model_displays 
      actions = []
      actions << {:format=>2, :action=>'new', :header=>'Create ' + self.name}  if (!ModelDisplay.by_model(self.id).by_action('new').present? && @new_model_display == 'y')
      actions << {:format=>2, :action=>'edit', :header=>'Edit ' + self.name} if (!ModelDisplay.by_model(self.id).by_action('edit').present? && @edit_model_display == 'y')
      actions << {:format=>1, :action=>'index', :header=>self.name.pluralize} if (!ModelDisplay.by_model(self.id).by_action('index').present? && @index_model_display == 'y')
      actions << {:format=>2, :action=>'show', :header=>self.name} if (!ModelDisplay.by_model(self.id).by_action('show').present? && @show_model_display == 'y')
      log_arr = []
      actions.each do | action |
        ModelDisplay.create(:model_id=>self.id, :format=>action[:format], :action=>action[:action], :header=>action[:header])
        # log_arr  << 'format: ' + action[:format] + ', action: ' + action[:action]
      end
    end
    def make_all_files
      # generate 'active_record:model', [self.classname]]
      mod = self.module.nil? || self.module.empty?  ? 'no_mod' : self.module
      logger.info("creating scaffold for " + self.classname + 'via: ' + 'rails g mega_bar:mega_bar ' + self.classname + ' ' + self.id.to_s)
      system 'rails g mega_bar:mega_bar_models ' + mod + ' ' + self.classname + ' ' + self.id.to_s
      ActiveRecord::Migrator.migrate "db/migrate"
    end

    def my_constantize(class_name)
      #not in use
      unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ class_name
        raise NameError, "#{class_name.inspect} is not a valid constant name!"
      end
      Object.module_eval("::#{$1}", __FILE__, __LINE__)
    end

    def standardize_module
      return if self.module.nil? || self.module.empty?
      self.module = self.module.gsub('megabar', 'MegaBar')
      self.module = self.module.chomp('::').chomp(':').chomp('/').reverse.chomp('::').chomp(':').chomp('/').reverse
      self.module = self.module.gsub('-', '_')
      self.module = self.module.gsub('/', '::')
      self.module = self.module.split('::').map { | m |
        m = m.gsub('-', '_')
        m = m.classify
      }.join('::')
    end

    def standardize_classname
      self.classname = self.classname.classify
    end

    def standardize_tablename # must come after standardize_module
      self.tablename = self.module.nil? || self.module.empty? ?   self.classname.pluralize.underscore : self.module.split('::').map { | m | m = m.underscore }.join('_') + '_' + self.classname.pluralize.underscore
    end
  end
end
#<Model id: 12, classname: nil, schema: "sqlite", tablename: "testers", name: "Tester", created_at: "2014-05-23 20:32:46", updated_at: "2014-05-23 20:32:46", default_sort_field: "id">