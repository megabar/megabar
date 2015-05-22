
Rails.application.routes.draw do

  MegaBar::Engine.routes.draw do  
    match '/model-displays/:id' => 'models_displays#show', via: :get
    MegaRoute.load('/mega-bar').each do |route|
      # puts "#{route[:path]} => #{route[:controller]}##{route[:action]} via #{route[:method]}"
      match route[:path] => "#{route[:controller]}##{route[:action]}", via: route[:method]
    end
  end
  puts "ended"
end



#    PUT    /models/:id(.:format)    mega_bar/models#update
#    PATCH  /models/:id(.:format)    mega_bar/models#update # resource!
#    PATCH  /models/:id(.:format)   mega_bar/models#update
