// Wait for both jQuery and the best_in_place plugin to be loaded
$(document).ready(function () {
  console.log('Document ready');
  console.log('jQuery version:', $.fn.jquery);
  console.log('best_in_place plugin:', typeof $.fn.best_in_place);

  // Check if the plugin is available
  if (typeof $.fn.best_in_place === 'function') {
    console.log('Activating best_in_place');
    /* Activating Best In Place */
    jQuery(".best_in_place").best_in_place();
  } else {
    console.error('jQuery best_in_place plugin not loaded');
    // Try to load it again
    $.getScript('https://raw.githubusercontent.com/bernat/best_in_place/master/lib/assets/javascripts/jquery.best_in_place.js')
      .done(function () {
        console.log('Plugin loaded, activating best_in_place');
        jQuery(".best_in_place").best_in_place();
      })
      .fail(function (jqxhr, settings, exception) {
        console.error('Failed to load plugin:', exception);
      });
  }
});