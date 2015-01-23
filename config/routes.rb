MegaBar::Engine.routes.draw do

  resources :field_displays, defaults: {model_id: 4}
  resources :fields, defaults: {model_id: 2}
  resources :model_displays, defaults: {model_id: 3}
  resources :models, defaults: {model_id: 1}
  resources :records_formats, defaults: {model_id: 5}
  resources :textboxes, defaults: {model_id: 6}
  resources :textreads, defaults: {model_id: 7}
  resources :selects, defaults: {model_id: 14}
end