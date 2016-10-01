module MegaBar
  class Template < ActiveRecord::Base
    has_many :template_sections
    validates_presence_of :name, allow_blank: false
    validates_presence_of :code_name, allow_blank: false
    validates_uniqueness_of :code_name
  end
end
