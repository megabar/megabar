module MegaBar 
  class Layable < ActiveRecord::Base
    belongs_to :layout
    belongs_to :layout_section
    belongs_to :template_section

    after_destroy :delete_dependents

    def delete_dependents
     #only destroy layoutsections if no other layables use it.
     LayoutSection.destroy(self.layout_section_id) if Layable.where(layout_section_id: self.layout_section_id).blank?
    end
  end
end 
