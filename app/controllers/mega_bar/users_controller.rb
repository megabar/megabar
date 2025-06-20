
module MegaBar 

  class UsersController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern    

    def get_options

      permission_levels = action_name == 'edit' ? 
        MegaBar::PermissionLevel.where(level: ..current_user.pll).pluck(:level_name, :id) :
        MegaBar::PermissionLevel.where(level: ..10).pluck(:level_name, :id)
        
      if MegaBar::User.count < 2
        permission_levels = MegaBar::PermissionLevel.all.pluck(:level_name, :id)
      end
      @options[:mega_bar_users] =  {
        permission_level_id: permission_levels,
      }
    end
  end
end 
