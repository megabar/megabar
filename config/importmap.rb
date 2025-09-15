# MegaBar Engine Importmap Configuration
# This file defines JavaScript modules specific to the MegaBar engine

# External dependencies (CDN-based for maximum compatibility)
pin "jquery", to: "https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js"
pin "autosize", to: "https://cdnjs.cloudflare.com/ajax/libs/autosize.js/6.0.1/autosize.min.js"

# Engine-generated files in host app
pin "add_jquery", to: "add_jquery.js"
pin "best_in_place", to: "best_in_place.js"
