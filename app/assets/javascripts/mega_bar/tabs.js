// Initialize tab functionality when DOM is ready
document.addEventListener('DOMContentLoaded', function () {
  const tabItems = document.querySelectorAll('.megaLayoutSectionTabs li');

  tabItems.forEach((tab, index) => {
    tab.addEventListener('click', function (e) {
      if (!this.classList.contains('active')) {
        // Remove active class from all tabs and content
        document.querySelectorAll('.megaLayoutSectionTabs li.active').forEach(el => el.classList.remove('active'));
        document.querySelectorAll('#content-tab div.active').forEach(el => el.classList.remove('active'));

        // Add active class to clicked tab
        this.classList.add('active');

        // Show corresponding content
        const contentDiv = document.querySelector(`#content-tab div:nth-child(${index + 1})`);
        if (contentDiv) {
          contentDiv.classList.add('active');
        }
      } else {
        // Toggle off if clicking active tab
        this.classList.remove('active');
        document.querySelector('#content-tab div.active')?.classList.remove('active');
      }
    });
  });
});
