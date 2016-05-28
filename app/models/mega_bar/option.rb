module MegaBar
  class Option < ActiveRecord::Base
    validates_presence_of :text, :value, :field_id
    validates_uniqueness_of :value, scope: :field_id,  message: "dupe option for this field"
    
  end
end
