module MegaBar
  class Field < ActiveRecord::Base
    belongs_to :model
    validates_presence_of :model_id, :tablename, :field
    validates_format_of :tablename, on: [:create, :update], :multiline => true, allow_nil: false, with: /[a-z]+/, message: 'no caps'
    validate :table_exists, on: :create unless Rails.env.test?
    after_create  :make_field_displays #, :only => [:create] #add update.
    before_create  :standardize_tablename
    after_create  :make_migration #, :only => [:create] #add update.
    after_save    :make_field_displays
    attr_accessor :new_field_display, :edit_field_display, :index_field_display, :show_field_display
    after_destroy :delete_field_displays
    #after_create :make_migration 
    scope :by_model, ->(model_id) { where(model_id: model_id) if model_id.present? }

    private

    def table_exists
      modle = Model.find(self.model_id) #this is a ugly dependency so this doesn't run in test environment.
      prefix = modle.modyule.nil? || modle.modyule.empty? ? '' : modle.modyule.split('::').map { | m | m.underscore }.join('_') + '_'
      self.tablename =  prefix + self.tablename if prefix + self.tablename == modle.tablename
      return true if ActiveRecord::Base.connection.table_exists? self.tablename
      errors.add(:base, 'That table does not exist')
      return false
    end
    def make_field_displays 
      actions = []
      index_model_display_id = ModelDisplay.by_model(self.model_id).by_action('index').pluck(:id).last
      show_model_display_id = ModelDisplay.by_model(self.model_id).by_action('show').pluck(:id).last
      new_model_display_id = ModelDisplay.by_model(self.model_id).by_action('new').pluck(:id).last
      edit_model_display_id = ModelDisplay.by_model(self.model_id).by_action('edit').pluck(:id).last
      actions << {:format=>'textread', model_display_id: index_model_display_id, :field_id=>self.id, :header=>self.field.pluralize}  if (!FieldDisplay.by_model_display_id(index_model_display_id).by_fields(self.id).present? && @index_field_display == 'y')
      actions << {:format=>'textread', model_display_id: show_model_display_id, :field_id=>self.id, :header=>self.field}  if (!FieldDisplay.by_model_display_id(show_model_display_id).by_fields(self.id).present? && @show_field_display == 'y')
      actions << {:format=>'textbox', model_display_id: new_model_display_id, :field_id=>self.id, :header=>self.field}  if (!FieldDisplay.by_model_display_id(new_model_display_id).by_fields(self.id).present? && @new_field_display == 'y')
      actions << {:format=>'textbox', model_display_id: edit_model_display_id, :field_id=>self.id, :header=>self.field}  if (!FieldDisplay.by_model_display_id(edit_model_display_id).by_fields(self.id).present? && @edit_field_display == 'y')
      actions.each do | action |
        FieldDisplay.create(model_display_id: action[:model_display_id],:field_id=>self.id, :format=>action[:format], :header=>action[:header])
      end
    end
    def standardize_tablename
     
    end
    def make_migration
      
      return if Model.connection.column_exists?(self.tablename,  self.field)

      system 'rails g mega_bar:mega_bar_fields ' + self.tablename + ' ' + self.field + ' ' + 'string'
      ActiveRecord::Migrator.migrate "db/migrate"
    end
    def delete_field_displays
      FieldDisplay.by_fields(self.id).destroy_all
    end
  end
end