MegaBar::Engine.routes.draw do

  resources :tests

  resources :testers

  resources :selects

  resources :field_displays

  resources :fields

  resources :textboxes

  resources :textreads

  resources :records_formats

  resources :attribute_displays

  resources :model_displays

  resources :attributes

  resources :models

  resources :tmp_models

  resources :tmp_fields
end
