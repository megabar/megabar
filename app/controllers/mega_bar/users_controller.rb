
module MegaBar 

  class UsersController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern    

    def get_options
      @options[:mega_bar_users] =  {
        permission_level_id: MegaBar::PermissionLevel.all.pluck(:level_name, :id),
      }
    end
  end
end 
