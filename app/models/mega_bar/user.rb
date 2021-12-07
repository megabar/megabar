module MegaBar
  class User < ActiveRecord::Base
    has_secure_password

    belongs_to :permission_level

    attr_accessor :pll, :pln

    def pll
      permission_level.present? ? permission_level.level : 0;
    end

    def pln
      permission_level.present? ? permission_level.level_name : 'Unauthenticated'
    end
  end
end 
