// MegaBar Tabs Module for Rails 8 importmap
console.log("MEGA_BAR: Tabs.js loaded");

// Make function globally available
window.initializeMegaBarTabs = initializeMegaBarTabs;

function initializeMegaBarTabs() {
  console.log("MEGA_BAR: Initializing tabs");
  const tabItems = document.querySelectorAll(".mega-layout-section-tabs li");
  console.log("MEGA_BAR: Found tab items:", tabItems.length);

  tabItems.forEach((tab, index) => {
    console.log("MEGA_BAR: Setting up click handler for tab:", index);
    tab.addEventListener("click", function (e) {
      e.preventDefault(); // Prevent any default link behavior
      console.log("MEGA_BAR: Tab clicked:", index);

      // Remove active class from all tabs and content
      document
        .querySelectorAll(".mega-layout-section-tabs li")
        .forEach((el) => el.classList.remove("active"));
      document.querySelectorAll(".tab-content").forEach((el) => {
        el.classList.remove("active");
        el.style.display = "none";
      });

      // Add active class to clicked tab
      this.classList.add("active");

      // Show corresponding content
      const contentDiv = document.querySelector(
        `#content-tab .tab-content:nth-child(${index + 1})`
      );
      console.log("MEGA_BAR: Found content div:", contentDiv);
      if (contentDiv) {
        contentDiv.classList.add("active");
        contentDiv.style.display = "block";
      }
    });
  });
}
