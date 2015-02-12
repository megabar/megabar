module MegaBar
  class Model < ActiveRecord::Base
    self.table_name = "mega_bar_models"
    include MegaBar::MegaBarModelConcern
    # validates_format_of :classname, :multiline => true, allow_nil: false, with: /([A-Z][a-z])\w+/
    validates_presence_of :classname
    validates :classname, format: { with: /\A[A-Za-z][A-Za-z0-9\-\_]*\z/, message: "Must start with a letter and have only letters, numbers, dashes or underscores" }
    validates_presence_of :default_sort_field
 
    has_many :fields, dependent: :destroy
    has_many :model_displays, dependent: :destroy
    before_create :standardize_modyule
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
      logger.info("creating scaffold for " + self.classname + 'via: ' + 'rails g mega_bar:mega_bar ' + self.classname + ' ' + self.id.to_s)
      mod = self.modyule.nil? || self.modyule.empty?  ? 'no_mod' : self.modyule
      # MegaBar.call_rails('mega_bar_models', {modyule: mod, classname: self.classname, model_id: self.id.to_s}) 
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

    def standardize_modyule
      return if self.modyule.nil? || self.modyule.empty?
      self.modyule = self.modyule.gsub('megabar', 'MegaBar')
      self.modyule = self.modyule.chomp('::').chomp(':').chomp('/').reverse.chomp('::').chomp(':').chomp('/').reverse
      self.modyule = self.modyule.gsub('-', '_')
      self.modyule = self.modyule.gsub('/', '::')
      self.modyule = self.modyule.split('::').map { | m |
        m = m.gsub('-', '_')
        m = m.classify
      }.join('::')
    end

    def standardize_classname
      self.classname = self.classname.classify
    end

    def standardize_tablename # must come after standardize_modyule
      self.tablename = self.modyule.nil? || self.modyule.empty? ?   self.classname.pluralize.underscore : self.modyule.split('::').map { | m | m = m.underscore }.join('_') + '_' + self.classname.pluralize.underscore
    end
  end
end