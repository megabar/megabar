// Date Picker functionality for MegaBar
$(document).ready(function () {

    // Initialize date pickers on page load
    initializeDatePickers();

    // Reinitialize date pickers when content is dynamically loaded
    $(document).on('DOMNodeInserted', function (e) {
        if ($(e.target).find('.datepicker-input').length > 0) {
            initializeDatePickers();
        }
    });

    function initializeDatePickers() {
        $('.datepicker-input').each(function () {
            var $input = $(this);

            // Skip if already initialized
            if ($input.hasClass('datepicker-initialized')) {
                return;
            }

            // Get configuration from data attributes
            var includeTime = $input.data('include-time') === true || $input.data('include-time') === 'true';
            var minDate = $input.data('min-date');
            var maxDate = $input.data('max-date');
            var defaultView = $input.data('default-view') || 'month';

            // Determine format based on include_time
            var format = includeTime ? 'YYYY-MM-DD HH:mm' : 'YYYY-MM-DD';

            // Use a simpler date picker if Tempus Dominus is not available
            if (typeof $.fn.datetimepicker !== 'undefined') {
                // Tempus Dominus configuration
                var config = {
                    format: format,
                    useCurrent: true,
                    sideBySide: includeTime,
                    showToday: true,
                    showClear: true,
                    showClose: true,
                    toolbarPlacement: 'bottom',
                    widgetPositioning: {
                        horizontal: 'auto',
                        vertical: 'bottom'
                    }
                };

                if (minDate) {
                    config.minDate = moment(minDate);
                }
                if (maxDate) {
                    config.maxDate = moment(maxDate);
                }

                $input.datetimepicker(config);
            } else {
                // Fallback to HTML5 date/datetime-local input
                if (includeTime) {
                    $input.attr('type', 'datetime-local');
                } else {
                    $input.attr('type', 'date');
                }

                if (minDate) {
                    $input.attr('min', minDate);
                }
                if (maxDate) {
                    $input.attr('max', maxDate);
                }
            }

            // Mark as initialized
            $input.addClass('datepicker-initialized');
        });
    }
}); 