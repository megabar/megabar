module MegaBar
  class TemplateSection < ActiveRecord::Base
    belongs_to :template
    validates_presence_of :name, allow_blank: false
    validates_presence_of :code_name, allow_blank: false
    validates_presence_of :template_id, allow_blank: false
    validates_uniqueness_of :code_name # scope to template_id
  end
end
