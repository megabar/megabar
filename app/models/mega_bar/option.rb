module MegaBar
  class Option < ActiveRecord::Base
    validates_presence_of :text, :value, :field_id
  end
end
