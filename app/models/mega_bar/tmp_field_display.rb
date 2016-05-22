module MegaBar
  class TmpFieldDisplay < ActiveRecord::Base
    validates_uniqueness_of :field_id, scope: :model_display_id, message: 'Field Ooops'
  end
end
