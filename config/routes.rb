MegaBar::Engine.routes.draw do
  
  resources :pages do 
    resources :layouts do
      resources :blocks
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
  # (leave that line in place with five
  root 'roots#root_page'
  ##### MEGABAR END #'s')
end
