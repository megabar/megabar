
Rails.application.routes.draw do

  MegaBar::Engine.routes.draw do
    # match '/models/:id' => "/models#show", via: :get, as: 'model'
    # resources :pages do
    #   resources :layouts do
    #     resources :blocks do
    #       resources :model_displays do
    #         resources :field_displays
    #       end
    #     end
    #   end
    # end
    # resources :blocks
    # resources :blocks
    # resources :field_displays
    # resources :fields
    # resources :layouts
    # resources :model_display_formats, path: '/model-display-formats'
    # resources :model_displays
    # resources :models
    # resources :options
    # resources :records_formats
    # resources :selects
    # resources :textboxes
    # resources :textreads
    MegaRoute.load('/mega-bar').each do |route|
      # puts "#{route[:path]} => #{route[:controller]}##{route[:action]} via #{route[:method]} as: #{route[:as]}" if route[:path].include?('models') || route[:path].include?('survey')
      # puts route;
      match route[:path] => "#{route[:controller]}##{route[:action]}", via: route[:method], as: route[:as]
    end
  end
end



#    PUT    /models/:id(.:format)    mega_bar/models#update
#    PATCH  /models/:id(.:format)    mega_bar/models#update # resource!
#    PATCH  /models/:id(.:format)   mega_bar/models#update
