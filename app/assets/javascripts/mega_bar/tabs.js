// Initialize tab functionality when DOM is ready
document.addEventListener('DOMContentLoaded', function () {
  console.log('Loading tab functionality...');

  const tabItems = document.querySelectorAll('.mega-layout-section-tabs li');
  console.log('Found', tabItems.length, 'tabs');

  tabItems.forEach((tab, index) => {
    tab.style.cursor = 'pointer';
    tab.addEventListener('click', function (e) {
      console.log('Tab clicked:', index, this.textContent);

      if (!this.classList.contains('active')) {
        // Remove active class from all tabs and content
        document.querySelectorAll('.mega-layout-section-tabs li.active').forEach(el => el.classList.remove('active'));
        document.querySelectorAll('#content-tab .tab-content.active').forEach(el => {
          el.classList.remove('active');
          el.style.display = 'none';
        });

        // Add active class to clicked tab
        this.classList.add('active');

        // Show corresponding content
        const contentDiv = document.querySelector(`#content-tab .tab-content:nth-child(${index + 1})`);
        if (contentDiv) {
          contentDiv.classList.add('active');
          contentDiv.style.display = 'block';
          console.log('Showing content for tab', index);
        } else {
          console.log('No content found for tab', index);
        }
      } else {
        // Toggle off if clicking active tab
        this.classList.remove('active');
        const activeContent = document.querySelector('#content-tab .tab-content.active');
        if (activeContent) {
          activeContent.classList.remove('active');
          activeContent.style.display = 'none';
        }
      }
    });
  });
});
