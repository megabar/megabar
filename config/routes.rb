MegaBar::Engine.routes.draw do
  resources :cymbals,  defaults: {model_id: 30}
   resources :microphones,  defaults: {model_id: 31}
   resources :flutes,  defaults: {model_id: 32}
   resources :tubas,  defaults: {model_id: 33}
   resources :picks,  defaults: {model_id: 34}
   resources :straps,  defaults: {model_id: 35}
   resources :violins,  defaults: {model_id: 37}
   resources :cellos,  defaults: {model_id: 38}
   resources :congas,  defaults: {model_id: 43}
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
  resources :killer_bees, path: '/killer-bees',  defaults: {model_id: 21}
 
 
 
end
