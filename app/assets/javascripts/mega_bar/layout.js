// Initialize layout functionality when DOM is ready
document.addEventListener('DOMContentLoaded', function () {
  // Handle layout section changes
  const layoutSelect = document.getElementById('layout_section_layout_ids');
  if (layoutSelect) {
    layoutSelect.addEventListener('change', function () {
      fetch('/mega-bar/template_sections_for_layout/3')
        .then(response => response.json())
        .then(data => {
          const options = document.querySelectorAll('#layout_section_template_section_id > option');
          options.forEach(option => {
            if (!data.includes(parseInt(option.value))) {
              option.remove();
            }
          });
        })
        .catch(error => console.error('Error:', error));
    });
  }

  // Initialize tooltips
  const tooltips = document.querySelectorAll('[data-bs-toggle="tooltip"]');
  tooltips.forEach(tooltip => {
    new bootstrap.Tooltip(tooltip);
  });
});
