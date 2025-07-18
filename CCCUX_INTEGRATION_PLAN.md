# CCCUX Integration Plan for Megabar

## Overview
This document outlines the step-by-step process for integrating CCCUX (CanCanCan UX) into Megabar, replacing the current simple permission system with a comprehensive role-based access control system.

## Current Megabar Authentication System Analysis

### Current Components:
- **User Model**: Uses `has_secure_password` with bcrypt
- **PermissionLevel Model**: Simple numeric permission levels
- **Authorization Logic**: In `MegaEnv` class checking `@user.pll >= permission_level`
- **No Devise**: Good for integration (no conflicts)

### Current Authorization Flow:
1. User logs in via `sessions_controller.rb`
2. `current_user` helper method in `application_controller.rb`
3. `check_authorization` in `mega_bar_concern.rb`
4. Permission checking in `MegaEnv#authorized?` method

## Integration Plan

### Phase 1: Remove Current Permission System

#### 1.1 Remove PermissionLevel Dependencies
```ruby
# Remove from User model
- belongs_to :permission_level
- def pll (permission level)
- def pln (permission level name)

# Remove from MegaEnv
- @user.pll >= permission_level checks
- Permission level based authorization
```

#### 1.2 Update User Model
```ruby
# Replace current User model with CCCUX User
module MegaBar
  class User < ActiveRecord::Base
    include Cccux::UserConcern
    
    has_secure_password  # Keep existing password system
    
    # Remove permission_level association
    # Remove pll and pln methods
    
    def name
      email
    end
  end
end
```

#### 1.3 Remove PermissionLevel Model
- Delete `app/models/mega_bar/permission_level.rb`
- Remove from database via migration
- Update any references in controllers/views

### Phase 2: Install CCCUX

#### 2.1 Add CCCUX to Gemfile
```ruby
# Add to megabar Gemfile
gem 'cccux', '~> 0.2.1'
```

#### 2.2 Run CCCUX Setup
```bash
# In megabar directory
bundle install
rails generate cccux:install
rails cccux:setup
```

#### 2.3 Update ApplicationController
```ruby
module MegaBar
  class ApplicationController < ActionController::Base
    include Cccux::ApplicationControllerConcern
    
    # Keep existing MegaBar functionality
    helper_method :sort_column, :sort_direction, :is_displayable, :might_paginate?, :might_filter?
    before_action :set_vars_for_all
    before_action :set_vars_for_displays
    
    # Replace check_authorization with CCCUX authorization
    # Remove: before_action :check_authorization
    # Add: CCCUX authorization methods
  end
end
```

### Phase 3: Update Authorization Logic

#### 3.1 Replace MegaEnv Authorization
```ruby
# In lib/mega_bar/mega_env.rb
def authorized?
  # Replace current permission level logic with CCCUX
  return true unless @user
  
  case @block_action
  when "index", "show", "all"
    @user.can?(:read, @klass)
  when "edit", "update"
    @user.can?(:update, @klass)
  when "create", "new"
    @user.can?(:create, @klass)
  when "destroy"
    @user.can?(:destroy, @klass)
  else
    true
  end
end
```

#### 3.2 Update Block Permissions
```ruby
# Replace block permission fields with CCCUX roles
# Instead of: permListAndView, permEditAndSave, etc.
# Use: CCCUX role assignments
```

### Phase 4: Create Migration Strategy

#### 4.1 Data Migration
```ruby
# Create migration to convert PermissionLevels to CCCUX Roles
class MigratePermissionLevelsToCccuxRoles < ActiveRecord::Migration[8.0]
  def up
    # Convert existing permission levels to CCCUX roles
    # Map numeric levels to appropriate roles
    # Create initial admin user if none exists
  end
  
  def down
    # Rollback strategy if needed
  end
end
```

#### 4.2 Update Database Schema
```ruby
# Remove permission_level_id from users table
# Add CCCUX tables (already done by cccux:setup)
```

### Phase 5: Update Controllers and Views

#### 5.1 Update Controllers
```ruby
# Replace permission checks in controllers
# Use CCCUX authorization helpers
# Update before_action filters
```

#### 5.2 Update Views
```ruby
# Add CCCUX authorization helpers to views
# Replace permission-based UI elements
# Add role management interface
```

### Phase 6: Create Megabar-Specific Roles

#### 6.1 Define Megabar Roles
```ruby
# Create roles specific to Megabar functionality
ROLES = {
  'Megabar Admin' => 'Full access to all Megabar functionality',
  'Page Manager' => 'Manage pages and their content',
  'Layout Manager' => 'Manage layouts and sections',
  'Block Manager' => 'Manage blocks and their content',
  'Model Manager' => 'Manage models and their displays',
  'Field Manager' => 'Manage fields and field displays',
  'Content Editor' => 'Edit content within assigned areas',
  'Viewer' => 'View-only access to assigned content'
}
```

#### 6.2 Create Role Setup Task
```ruby
# Create rake task to set up Megabar-specific roles
namespace :megabar do
  desc "Set up CCCUX roles for Megabar"
  task setup_roles: :environment do
    # Create Megabar-specific roles
    # Set up default permissions
    # Create initial admin user
  end
end
```

### Phase 7: Update Authorization for Complex Hierarchy

#### 7.1 Implement Page Manager Authorization
```ruby
# For the Page → Layout → Block → Model-Display → Field-Display hierarchy
class MegabarAuthorizationService
  def initialize(user, resource)
    @user = user
    @resource = resource
  end

  def can_manage_page_content?
    return false unless @user
    
    # Check if user is a page manager for this resource's page
    page = find_owning_page(@resource)
    return false unless page
    
    @user.can?(:manage, page)
  end

  private

  def find_owning_page(resource)
    case resource
    when MegaBar::Page
      resource
    when MegaBar::Layout
      resource.page
    when MegaBar::Block
      resource.layout.page
    when MegaBar::ModelDisplay
      resource.block.layout.page
    when MegaBar::FieldDisplay
      resource.model_display.block.layout.page
    end
  end
end
```

#### 7.2 Update Ability Class
```ruby
# Extend CCCUX Ability class for Megabar
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    # Add Megabar-specific authorization rules
    user.roles.each do |role|
      role.role_abilities.each do |ra|
        permission = ra.ability_permission
        
        case permission.subject
        when 'MegaBar::Page'
          if permission.action == 'manage' && ra.ownership_type == 'owned'
            # Page managers can manage everything under their pages
            can permission.action.to_sym, permission.subject.constantize, 
                id: user.page_manager_pages.pluck(:id)
            
            # Also allow access to all child resources
            can permission.action.to_sym, [MegaBar::Layout, MegaBar::Block, MegaBar::ModelDisplay, MegaBar::FieldDisplay] do |resource|
              resource.page_id.in?(user.page_manager_pages.pluck(:id))
            end
          end
        end
      end
    end
  end
end
```

### Phase 8: Testing and Validation

#### 8.1 Update Tests
```ruby
# Update existing tests to use CCCUX authorization
# Add tests for new role-based permissions
# Test complex hierarchy authorization
```

#### 8.2 Integration Testing
```ruby
# Test complete workflow with CCCUX
# Verify all existing functionality still works
# Test new role-based features
```

## Implementation Order

### Week 1: Foundation
1. Add CCCUX gem to Megabar
2. Run CCCUX setup
3. Create migration to remove PermissionLevel system
4. Update User model

### Week 2: Core Integration
1. Update ApplicationController
2. Replace authorization logic in MegaEnv
3. Update controllers to use CCCUX
4. Create Megabar-specific roles

### Week 3: Advanced Features
1. Implement complex hierarchy authorization
2. Update views with CCCUX helpers
3. Create admin interface for role management
4. Add comprehensive testing

### Week 4: Polish and Documentation
1. Update documentation
2. Create migration guide
3. Performance testing
4. Final validation

## Benefits of Integration

### For Developers:
- **Comprehensive RBAC**: Full role-based access control
- **Flexible Permissions**: Granular control over actions and resources
- **Admin Interface**: Built-in UI for managing roles and permissions
- **Extensible**: Easy to add new roles and permissions

### For End Users:
- **Better UX**: Clear permission management interface
- **Flexible Roles**: Assign multiple roles to users
- **Contextual Permissions**: Different permissions in different contexts
- **Audit Trail**: Track permission changes and access

### For Megabar:
- **Enterprise Ready**: Professional-grade authorization system
- **Scalable**: Handles complex permission scenarios
- **Maintainable**: Clean, well-documented authorization code
- **Future Proof**: Easy to extend for new features

## Risk Mitigation

### Backward Compatibility:
- Maintain existing user sessions during migration
- Provide rollback strategy
- Test thoroughly before deployment

### Performance:
- Cache authorization results where appropriate
- Optimize database queries for permission checks
- Monitor performance impact

### Security:
- Thorough testing of all authorization paths
- Validate permission inheritance
- Audit all permission changes

## Success Metrics

### Technical:
- All existing functionality preserved
- New role-based features working
- Performance maintained or improved
- Test coverage >90%

### User Experience:
- Clear role management interface
- Intuitive permission assignment
- Fast authorization checks
- Comprehensive audit logging

This integration will transform Megabar from a simple permission system to a comprehensive, enterprise-ready authorization platform while maintaining all existing functionality. 