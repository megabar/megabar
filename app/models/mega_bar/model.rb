module MegaBar
  class Model < ActiveRecord::Base

    include MegaBar::MegaBarModelConcern

    after_create  :make_all_files
    after_create  :make_page_for_model
    after_save    :make_position_field
    attr_accessor :make_page
    attr_writer   :model_id
    before_create :standardize_modyule
    before_create :standardize_classname
    before_create :standardize_tablename
    has_many      :fields, dependent: :destroy
    scope         :by_model, ->(model_id) { where(id: model_id) if model_id.present? }
    validates     :classname, format: { with: /\A[A-Za-z][A-Za-z0-9\-\_]*\z/, message: "Must start with a letter and have only letters, numbers, dashes or underscores" }
    validates_presence_of :default_sort_field, :name
    validates_uniqueness_of :classname


    private

    def make_all_files
      make_position_field
      # generate 'active_record:model', [self.classname]]
      logger.info("creating scaffold for " + self.classname + 'via: ' + 'rails g mega_bar:mega_bar ' + self.classname + ' ' + self.id.to_s)
      mod = self.modyule.nil? || self.modyule.empty?  ? 'no_mod' : self.modyule
      # MegaBar.call_rails('mega_bar_models', {modyule: mod, classname: self.classname, model_id: self.id.to_s})
      system 'rails g mega_bar:mega_bar_models ' + mod + ' ' + self.classname + ' ' + self.id.to_s
      ActiveRecord::Migrator.migrate "db/migrate"
    end

    def make_page_for_model
      if !self.make_page.nil? && !self.make_page.empty?
        mod = self.modyule.nil? || self.modyule.empty?  ? '' : self.modyule.underscore + '/'
        path = '/' + mod.dasherize + self.classname.underscore.dasherize.pluralize
        # path = self.make_page == 'default_model_path' ? path : self.make_page
        Page.create(name: self.name + ' Model Page', path: path, make_layout_and_block: 'y', base_name: self.name, model_id: self.id )
      end
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

    def make_position_field
      return unless MegaBar::Field.by_model(self.id).where(field: 'position').empty?
      mds = find_model_displays_for_position_fields
      Field.create(model_id: self.id, field: 'position', tablename: self.tablename, data_type: 'integer', default_data_format: 'textread', default_data_format_edit: 'textbox', model_display_ids: mds)
      parent_model = MegaBar::Model.find_by(modyule: self.position_parent.split("::")[0...-1].join("::"), classname: self.position_parent.split("::").last)
      populate_positions(parent_model)
    end

    def find_model_displays_for_position_fields
      mds = []
      Block.find(ModelDisplay.by_model(self.id).by_action("index").pluck(:block_id)).each do |block|
        mds << block.model_displays.by_action("index").pluck(:id).first
      end
      mds
    end
    def populate_positions(parent_model)
      # modle = Model.find(model_id)
      # modle_name = modle.modyule ? modle.modyule + "::" + modle.classname : modle.classname
      modle_name = self.modyule ? self.modyule + "::" + self.classname : self.classname
      mod = modle_name.constantize
      mod.reset_column_information

      # mod.distinct(fk).map(&parent_model.classname.downcase.to_sym).each {|parent| parent.send(self.classname.downcase.pluralize.to_sym).order(:id).each_with_index { |child, i| puts 'position for ' +child.id.to_s+ ' would be ' + i.to_s}}
      mod.distinct((parent_model.classname.downcase + '_id').to_sym).map(&parent_model.classname.downcase.to_sym).each do |parent|
        parent.send(self.classname.underscore.downcase.pluralize.to_sym).order(:id).each_with_index do |child, i|
          child.update_columns(position: i + 1)
        end
      end
    end
  end
end
