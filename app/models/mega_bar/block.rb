module MegaBar 
  class Block < ActiveRecord::Base
    belongs_to :layout
    scope :by_layout, ->(layout_id) { where(layout_id: layout_id) if layout_id.present? }
    scope :by_actions, ->(action) {
      if action.present? 
        case action
        when 'show'
          where(actions: ['all', 'sine', 'show'])
        when 'index'
          where(actions: ['all', 'sine', 'index'])
        when 'new'
          where(actions: ['all', 'sine', 'new'])
        when 'edit'
          where(actions: ['all', 'sine', 'edit'])
        when 'create'
          where(actions: ['all'])
        when 'update'
          where(actions: ['all'])
        when 'delete'
          where(actions: ['all'])
        else
          where(action: ['all', action])
        end
      end
    }
  end
end 
