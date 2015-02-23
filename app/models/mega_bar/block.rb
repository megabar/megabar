module MegaBar 
  class Block < ActiveRecord::Base
    belongs_to :layout
    scope :by_layout, ->(layout_id) { where(layout_id: layout_id) if layout_id.present? }
    scope :by_actions, ->(action) {
      if action.present? 
        case action
        when 'show'
          where(actions: ['all', 'sine', 'show', 'current'])
        when 'index'
          where(actions: ['all', 'sine', 'index', 'current'])
        when 'new'
          where(actions: ['all', 'sine', 'new', 'current'])
        when 'edit'
          where(actions: ['all', 'sine', 'edit', 'current'])
        when 'create'
          where(actions: ['all', 'current'])
        when 'update'
          where(actions: ['all', 'current'])
        when 'delete'
          where(actions: ['all', 'current'])
        else
          where(action: ['all', 'current', action])
        end
      end
    }
    has_many :model_displays, dependent: :destroy
    scope :by_model, ->(model_id) { where(id: model_id) if model_id.present? }
    after_save :make_model_displays
    attr_accessor  :model_id, :new_model_display, :edit_model_display, :index_model_display, :show_model_display
    

    def make_model_displays 
      if self.model_id
        model_name = Model.find(self.model_id).name
        actions = []
        actions << {:format=>2, :action=>'new', :header=>'Create ' + model_name.singularize}  if (!ModelDisplay.by_block(self.id).by_action('new').present? && @new_model_display == 'y')
        actions << {:format=>2, :action=>'edit', :header=>'Edit ' + model_name.singularize} if (!ModelDisplay.by_block(self.id).by_action('edit').present? && @edit_model_display == 'y')
        actions << {:format=>1, :action=>'index', :header=>model_name.pluralize} if (!ModelDisplay.by_block(self.id).by_action('index').present? && @index_model_display == 'y')
        actions << {:format=>2, :action=>'show', :header=>model_name.singularize} if (!ModelDisplay.by_block(self.id).by_action('show').present? && @show_model_display == 'y')
        log_arr = []
        actions.each do | action |
          md = ModelDisplay.create(:block_id=>self.id, model_id: self.model_id, :format=>action[:format], :action=>action[:action], :header=>action[:header])
        end
      end
    end
  end
end
