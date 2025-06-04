// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require bootstrap/dist/js/bootstrap.bundle.min.js
//= require jquery.best_in_place
//= require best_in_place
//= require best_in_place.jquery-ui
//= require_tree .

// Import jQuery and its plugins
import "jquery"
import "jquery_ujs"
import "jquery-ui"
import "bootstrap/dist/js/bootstrap.bundle.min.js"

// Import custom JavaScript files
import "./layout"
import "./tabs"
import "./best_in_place"
