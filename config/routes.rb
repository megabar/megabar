MegaBar::Engine.routes.draw do
  
  resources :model_display_formats, path: '/model-display-formats'
  resources :options
  resources :pages do 
    resources :layouts
  end
  resources :layouts
  resources :blocks
  ##### MEGABAR END
  root 'roots#root_page'

   # (leave that line in place with five #'s')

  resources :blocks
  resources :layouts
  resources :pages
  
  resources :field_displays
  resources :fields
  resources :model_displays
  resources :models
  resources :records_formats
  resources :textboxes
  resources :textreads
  resources :selects
end
