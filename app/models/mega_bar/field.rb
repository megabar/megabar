module MegaBar
  class Field < ActiveRecord::Base
    after_create  :make_migration #, :only => [:create] #add update.
    after_destroy :delete_field_displays
    after_save    :make_field_displays
    attr_accessor :model_display_ids, :new_field_display, :edit_field_display, :index_field_display, :show_field_display, :block_id
    before_create :standardize_tablename
    belongs_to    :model
    has_many      :options, dependent: :destroy
    scope         :by_model, ->(model_id) { where(model_id: model_id) if model_id.present? }
    validate      :table_exists, on: :create unless Rails.env.test?
    validates_format_of :tablename, on: [:create, :update], :multiline => true, allow_nil: false, with: /[a-z]+/, message: 'no caps'
    validates_presence_of :model_id, :tablename, :field, :default_data_format, :default_data_format_edit
    validates_uniqueness_of :field, scope: :model_id,  message: "dupe field for this model"

    private

    def table_exists
      return true if self.tablename == 'accessor'
      modle = Model.find(self.model_id) #this is a ugly dependency so this doesn't run in test environment.
      prefix = modle.modyule.nil? || modle.modyule.empty? ? '' : modle.modyule.split('::').map { | m | m.underscore }.join('_') + '_'
      self.tablename =  prefix + self.tablename if prefix + self.tablename == modle.tablename
      return true if ActiveRecord::Base.connection.table_exists? self.tablename
      errors.add(:base, 'That table does not exist')
      return false
    end

    def make_field_displays
      # return unless self.model_display_ids.present?
      byebug
      self.model_display_ids = self.model_display_ids.reject(&:blank?)
      mds = ModelDisplay.find(self.model_display_ids) if self.model_display_ids.present?
      mds.each do | md |
        data_display = ['new', 'edit'].include?(md.action) ? self.default_data_format_edit :  self.default_data_format
        FieldDisplay.create(model_display_id: md.id, field_id: self.id, format:data_display, header: self.field.humanize)
      end
    end

    def standardize_tablename

    end

    def make_migration
      return true if self.accessor == 'y'
      return if Model.connection.column_exists?(self.tablename,  self.field)
      system 'bundle exec rails g mega_bar:mega_bar_fields ' + self.tablename + ' ' + self.field + ' ' + self.data_type
      ActiveRecord::Migrator.migrate "db/migrate"
      system 'rake db:schema:dump'
    end
    def delete_field_displays
      FieldDisplay.by_fields(self.id).destroy_all
    end
  end
end
