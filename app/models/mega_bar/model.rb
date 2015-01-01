module MegaBar
  class Model < ActiveRecord::Base
    self.table_name = "mega_bar_models"
    include MegaBar::MegaBarModelConcern
    after_create  :make_model_displays
    after_create :make_all_files
    after_save :make_model_displays
    #has_many :attributes #ack you can't do this!  http://reservedwords.herokuapp.com/words/attributes
    attr_accessor :model_id, :new_model_display, :edit_model_display, :index_model_display, :show_model_display
    attr_writer :model_id
    scope :by_model, ->(model_id) { where(id: model_id) if model_id.present? }
    def make_model_displays 
      return if ENV['mega_bar_data_loading'] == 'yes'
      actions = []
      actions << {:format=>2, :action=>'new', :header=>'Create ' + self.name}  if (!ModelDisplay.by_model(self.id).by_action('new').present? && @new_model_display == 'y')
      actions << {:format=>2, :action=>'edit', :header=>'Edit ' + self.name} if (!ModelDisplay.by_model(self.id).by_action('edit').present? && @edit_model_display == 'y')
      actions << {:format=>1, :action=>'index', :header=>self.name.pluralize} if (!ModelDisplay.by_model(self.id).by_action('index').present? && @index_model_display == 'y')
      actions << {:format=>2, :action=>'show', :header=>'Show' + self.name} if (!ModelDisplay.by_model(self.id).by_action('show').present? && @show_model_display == 'y')
      log_arr = []
      actions.each do | action |
        ModelDisplay.create(:model_id=>self.id, :format=>action[:format], :action=>action[:action], :header=>action[:header])
        # log_arr  << 'format: ' + action[:format] + ', action: ' + action[:action]
      end
      logger.info 'Made model displays for:' + log_arr.join(', ')
    end
    def make_all_files
      return if ENV['mega_bar_data_loading'] == 'yes'
     # generate 'active_record:model', [self.classname]
      logger.info("creating scaffold for " + self.classname + 'via: ' + 'rails g mega_bar:mega_bar ' + self.classname + ' ' + self.id.to_s)
      system 'rails g mega_bar:mega_bar ' + self.classname + ' ' + self.id.to_s
      ActiveRecord::Migrator.migrate "db/migrate"
    end
  end
end
#<Model id: 12, classname: nil, schema: "sqlite", tablename: "testers", name: "Tester", created_at: "2014-05-23 20:32:46", updated_at: "2014-05-23 20:32:46", default_sort_field: "id">