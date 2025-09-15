// MegaBar engine jQuery globalizer
import jquery from "jquery";
import autosize from "autosize";

// Make jQuery globally available for legacy code
window.jQuery = jquery;
window.$ = jquery;

// Make autosize available as jQuery plugin
jquery.fn.autosize = function () {
  this.each(function () {
    autosize(this);
  });
  return this;
};

console.log("MegaBar: jQuery globalizer loaded");
