# MegaBar Engine Importmap Configuration
# This file defines JavaScript modules specific to the MegaBar engine.

# pin "mega_bar/application", to: "mega_bar/application.js"
# pin_all_from MegaBar::Engine.root.join("app/javascript/mega_bar"), under: "mega_bar"



pin "mega_bar/application", to: "mega_bar/application.js"

# Pin all other files from the engine's app/javascript/mega_bar directory
pin_all_from File.expand_path("../app/javascript/mega_bar", __dir__), under: "mega_bar"

