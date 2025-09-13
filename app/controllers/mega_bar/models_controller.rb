module MegaBar
  class ModelsController < ApplicationController
    include MegaBarConcern
    include MegaBar::AuthorizationConcern

    def index
      @mega_instance ||= Model.where.not(modyule: 'MegaBar').order(column_sorting)
      super
    end
    def all
      @mega_instance = Model.all.order(column_sorting) # .page(@page_number).per(5)
      index
    end

    def filter_displays
      return unless Page.by_route('/' + @mega_instance.classname.underscore.dasherize.pluralize).present?

      @mega_displays[0][:displayable_fields] = @mega_displays[0][:displayable_fields].reject do |df|
        df[:field].field == 'make_page'
      end

    end

    def get_options
      @options[:mega_bar_models] =  {
        position_parent: MegaBar::Model.all.pluck(:name, :modyule, :classname).map{|a|  
          modyule = a[1] || 'No Module'
          [modyule + ' - ' + a[0], modyule + '::' + a[2]]
        }.unshift(['Position with No Parent', 'pnp']),
        default_sort_field: Field.by_model(params[:id]).pluck("field, field"),
        make_page: Template.all.pluck("name, id")
            }
      
      # Add title_field_id options for edit forms
      if params[:id].present?
        existing_fields = Field.by_model(params[:id]).pluck("field, id")
        @options[:mega_bar_models][:title_field_id] = existing_fields.unshift(['No Title Field', ''])
      end
    end
  end
end
