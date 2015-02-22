module MegaBar
  class Model < ActiveRecord::Base
    include MegaBar::MegaBarModelConcern

    after_create  :make_all_files
    after_create  :make_page_for_model
    attr_accessor :make_page
    attr_writer   :model_id
    before_create :standardize_modyule
    before_create :standardize_classname
    before_create :standardize_tablename
    has_many      :fields, dependent: :destroy
    scope         :by_model, ->(model_id) { where(id: model_id) if model_id.present? }
    validate      :classname, format: { with: /\A[A-Za-z][A-Za-z0-9\-\_]*\z/, message: "Must start with a letter and have only letters, numbers, dashes or underscores" }
    validates_presence_of :default_sort_field
    validates_uniqueness_of :classname

    private

    def make_all_files
      # generate 'active_record:model', [self.classname]]
      logger.info("creating scaffold for " + self.classname + 'via: ' + 'rails g mega_bar:mega_bar ' + self.classname + ' ' + self.id.to_s)
      mod = self.modyule.nil? || self.modyule.empty?  ? 'no_mod' : self.modyule
      # MegaBar.call_rails('mega_bar_models', {modyule: mod, classname: self.classname, model_id: self.id.to_s}) 
      system 'rails g mega_bar:mega_bar_models ' + mod + ' ' + self.classname + ' ' + self.id.to_s
      ActiveRecord::Migrator.migrate "db/migrate"
    end

    def make_page_for_model
      mod = self.modyule.nil? || self.modyule.empty?  ? '' : self.modyule.underscore + '/'
      path = mod + self.tablename
      Page.create(name: self.name + ' Model Page', path: path, make_layout_and_block: 'y' )
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