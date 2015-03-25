MegaBar::Engine.routes.draw do
  
  resources :pages do 
    resources :layouts do
      resources :blocks do
        resources :model_displays do
          resources :field_displays
        end
      end
    end
  end
  resources :blocks
  resources :blocks
  resources :field_displays
  resources :fields
  resources :layouts
  resources :model_display_formats, path: '/model-display-formats'
  resources :model_displays
  resources :models
  resources :options
  resources :records_formats
  resources :selects
  resources :textboxes
  resources :textreads
  root 'roots#root_page'
 resources :mega_bar_models, path: 'y'
  resources :mega_bar_models, path: 'y'
  resources :mega_bar_models, path: 'y'
  resources :mega_bar_models, path: 'y'
   ##### MEGABAR END
  # (leave that line in place with five #'s')
end
