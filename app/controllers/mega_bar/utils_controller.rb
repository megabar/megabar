module MegaBar 
  class UtilsController <  ActionController::Base
 
    def by_layout
      render json: TemplateSection.where(template_id:  Layout.find(31).template_id).pluck(:id)
    end

  end
end
