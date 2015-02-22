module MegaBar 
  class Block < ActiveRecord::Base
    belongs_to :layout
    scope :by_model, ->(model_id) { where(id: model_id) if model_id.present? }
    after_save :make_model_displays
    attr_accessor :new_model_display, :edit_model_display, :index_model_display, :show_model_display
    

    def make_model_displays 

      actions = []
      actions << {:format=>2, :action=>'new', :header=>'Create ' + self.name}  if (!ModelDisplay.by_model(self.id).by_action('new').present? && @new_model_display == 'y')
      actions << {:format=>2, :action=>'edit', :header=>'Edit ' + self.name} if (!ModelDisplay.by_model(self.id).by_action('edit').present? && @edit_model_display == 'y')
      actions << {:format=>1, :action=>'index', :header=>self.name.pluralize} if (!ModelDisplay.by_model(self.id).by_action('index').present? && @index_model_display == 'y')
      actions << {:format=>2, :action=>'show', :header=>self.name} if (!ModelDisplay.by_model(self.id).by_action('show').present? && @show_model_display == 'y')
      log_arr = []
      byebug
      actions.each do | action |
        ModelDisplay.create(:block_id=>self.id, :format=>action[:format], :action=>action[:action], :header=>action[:header])
        # log_arr  << 'format: ' + action[:format] + ', action: ' + action[:action]
      end
    end
  end
end 