class DynoRoute
  def self.load
    MegaBar::Engine.routes.draw do
      Page.all.each do |pg|
        puts "Routing #{pg.name}"
        # get "/#{pg.name}", :to => "pages#show", defaults: { id: pg.id }
      end
    end
  end

  def self.reload
    ComingSoon::Application.routes_reloader.reload!
  end
  def self.boop
    abort('booop')
  end
end
