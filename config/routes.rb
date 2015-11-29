
Rails.application.routes.draw do
  MegaBar::Engine.routes.draw do
    MegaRoute.load('/mega-bar').each do |route|
      # puts "#{route[:path]} => #{route[:controller]}##{route[:action]} via #{route[:method]} as: #{route[:as]}" if route[:path].include?('models') || route[:path].include?('survey')
      # puts route;
      match route[:path] => "#{route[:controller]}##{route[:action]}", via: route[:method], as: route[:as]
    end
  end

end
