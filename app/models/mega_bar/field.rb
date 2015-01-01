module MegaBar
  class Field < ActiveRecord::Base
    belongs_to :model
    has_many :field_display
    after_create  :make_field_displays #, :only => [:create] #add update.
    after_create  :make_migration #, :only => [:create] #add update.
    after_save :make_field_displays
    attr_accessor :new_field_display, :edit_field_display, :index_field_display, :show_field_display
    
    #after_create :make_migration 
    scope :by_model, ->(model_id) { where(model_id: model_id) if model_id.present? }
    def make_field_displays 
      return if ENV['mega_bar_data_loading'] == 'yes'
      actions = []
      actions << {:format=>'textread', :action=>'index', :field_id=>self.id, :header=>self.field.pluralize}  if (!FieldDisplay.by_fields(self.id).by_action('index').present? && @index_field_display == 'y')
      actions << {:format=>'textread', :action=>'show', :field_id=>self.id, :header=>self.field}  if (!FieldDisplay.by_fields(self.id).by_action('show').present? && @show_field_display == 'y')
      actions << {:format=>'textbox', :action=>'new', :field_id=>self.id, :header=>self.field}  if (!FieldDisplay.by_fields(self.id).by_action('new').present? && @new_field_display == 'y')
      actions << {:format=>'textbox', :action=>'edit', :field_id=>self.id, :header=>self.field}  if (!FieldDisplay.by_fields(self.id).by_action('edit').present? && @edit_field_display == 'y')
      actions.each do | action |
        FieldDisplay.create(:field_id=>self.id, :format=>action[:format], :action=>action[:action], :header=>action[:header])
      end
    end
    def make_migration
      return if ENV['mega_bar_data_loading'] == 'yes'
      return if Model.connection.column_exists?(self.tablename, self.field)
      system 'rails g mega_bar:mega_bar_fields ' + self.tablename + ' ' + self.field + ' ' + 'string'
      ActiveRecord::Migrator.migrate "db/migrate"
    end

  end
end