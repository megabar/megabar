MegaBar::Engine.routes.draw do
  
   resources :sands,  defaults: {model_id: 25}
   resources :vows,  defaults: {model_id: 26}
   ##### MEGABAR END



   # (leave that line in place with five #'s')


  resources :field_displays, defaults: {model_id: 4}
  resources :fields, defaults: {model_id: 2}
  resources :model_displays, defaults: {model_id: 3}
  resources :models, defaults: {model_id: 1}
  resources :records_formats, defaults: {model_id: 5}
  resources :textboxes, defaults: {model_id: 6}
  resources :textreads, defaults: {model_id: 7}
  resources :selects, defaults: {model_id: 14}
end
