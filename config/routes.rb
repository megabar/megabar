MegaBar::Engine.routes.draw do
  
   resources :model_display_formats, path: '/model-display-formats',  defaults: {model_id: 15}
   resources :options,  defaults: {model_id: 17}
   ##### MEGABAR END
  root 'roots#root_page'



   # (leave that line in place with five #'s')

  resources :blocks, defaults: {model_id: 21}
  resources :layouts, defaults: {model_id: 20}
  resources :pages, defaults: {model_id: 18}
  
  resources :field_displays, defaults: {model_id: 4}
  resources :fields, defaults: {model_id: 2}
  resources :model_displays, defaults: {model_id: 3}
  resources :models, defaults: {model_id: 1}
  resources :records_formats, defaults: {model_id: 5}
  resources :textboxes, defaults: {model_id: 6}
  resources :textreads, defaults: {model_id: 7}
  resources :selects, defaults: {model_id: 14}
end
