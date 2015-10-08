module MegaBar
  class Field < ActiveRecord::Base
    after_create  :make_migration #, :only => [:create] #add update.
    after_destroy :delete_field_displays
    after_save    :make_field_displays
    attr_accessor :new_field_display, :edit_field_display, :index_field_display, :show_field_display, :block_id
    before_create :standardize_tablename
    belongs_to    :model
    has_many      :options, dependent: :destroy
    scope         :by_model, ->(model_id) { where(model_id: model_id) if model_id.present? }
    validate      :table_exists, on: :create unless Rails.env.test?
    validates_format_of :tablename, on: [:create, :update], :multiline => true, allow_nil: false, with: /[a-z]+/, message: 'no caps'
    validates_presence_of :model_id, :tablename, :field, :default_data_format, :default_data_format_edit

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
      model_displays = mds = ModelDisplay.by_block(self.block_id)
      actions = []
      actions << {format: 'textread', model_display_id: mds.by_action('index').last.id,  header: self.field.humanize} if (!mds.by_action('index').last.nil? && !FieldDisplay.by_model_display_id(mds.by_action('index').last.id).by_fields(self.id).present? && @index_field_display == 'y')
      actions << {format: 'textread', model_display_id: mds.by_action('show').last.id,  header: self.field.humanize} if (!mds.by_action('show').last.nil? && !FieldDisplay.by_model_display_id(mds.by_action('show').last.id).by_fields(self.id).present? && @show_field_display == 'y')
      actions << {format: self.default_data_format, model_display_id: mds.by_action('new').last.id, header:self.field.humanize} if (!mds.by_action('new').last.nil? && !FieldDisplay.by_model_display_id(mds.by_action('new').last.id).by_fields(self.id).present? && @new_field_display == 'y')
      actions << {format: self.default_data_format_edit, model_display_id: mds.by_action('edit').last.id, header: self.field.humanize} if (!mds.by_action('edit').last.nil? && !FieldDisplay.by_model_display_id(mds.by_action('edit').last.id).by_fields(self.id).present? && @edit_field_display == 'y')
      actions.each do | action |
        FieldDisplay.create(model_display_id: action[:model_display_id], field_id: self.id, format:action[:format], header: action[:header])
      end
    end
    def standardize_tablename

    end
    def make_migration
      return true if self.accessor == 'y'
      return if Model.connection.column_exists?(self.tablename,  self.field)
      system 'rails g mega_bar:mega_bar_fields ' + self.tablename + ' ' + self.field + ' ' + self.data_type
      ActiveRecord::Migrator.migrate "db/migrate"
      system 'rake db:schema:dump'
    end
    def delete_field_displays
      FieldDisplay.by_fields(self.id).destroy_all
    end
  end
end
