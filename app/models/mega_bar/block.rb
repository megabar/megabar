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
  end
end 
