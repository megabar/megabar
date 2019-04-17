Rails.application.routes.draw do
  MegaBar::Engine.routes.draw do
    MegaRoute.load('/mega-bar').each do |route|
      get '/template_sections_for_layout/:id', to: 'utils#by_layout'
      # puts "MB: HEY: #{route[:path]} => #{route[:controller]}##{route[:action]} via #{route[:method]} as: #{route[:as]}" # if route[:path].include?('models') || route[:path].include?('survey')
      # puts route;
      # if route[:concerns] == 'paginatable'
      #   # puts("#{route[:path]}(/#{route[:controller].singularize}_page/:page)")
      #   match "#{route[:path]}(/#{route[:controller].singularize}_page/:page)" => "#{route[:controller]}##{route[:action]}", via: route[:method], as: route[:as], :page => 1
      # else
      match route[:path] => "#{route[:controller]}##{route[:action]}", via: route[:method], as: route[:as]
      # end
    end
  end
  devise_for :users, class_name: "MegaBar::User", module: :devise
end
