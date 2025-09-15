// MegaBar Engine JavaScript for Rails 8+ importmap
// This file provides Rails 8 importmap compatibility for the MegaBar engine

// jQuery setup - CRITICAL ORDER!
import "mega_bar/add_jquery"; // Import this FIRST to make jQuery global
import "jquery";

// Dependencies
import "autosize";

// MegaBar specific modules
import "mega_bar/best_in_place";
import "mega_bar/tabs";
import "mega_bar/layout";

// Initialize when DOM is ready
document.addEventListener("DOMContentLoaded", function () {
  console.log("MegaBar: DOM loaded, initializing...");
  console.log("MegaBar: jQuery available:", typeof $ !== "undefined");
  console.log(
    "MegaBar: jQuery version:",
    typeof $ !== "undefined" ? $.fn.jquery : "N/A"
  );
  console.log(
    "MegaBar: best_in_place available:",
    typeof $ !== "undefined" && $.fn.best_in_place
  );

  // Initialize best_in_place
  if (typeof $ !== "undefined" && $.fn.best_in_place) {
    console.log("MegaBar: Initializing best_in_place...");
    $(".best_in_place").best_in_place();
    console.log("MegaBar: best_in_place initialized!");
  } else {
    console.log("MegaBar: best_in_place not available");
  }

  // Initialize other MegaBar components
  if (typeof $ !== "undefined") {
    // Initialize tabs if present
    if (typeof initializeMegaBarTabs === "function") {
      initializeMegaBarTabs();
    }

    // Initialize layout if present
    if (typeof initializeMegaBarLayout === "function") {
      initializeMegaBarLayout();
    }
  }

  console.log("MegaBar: Initialization complete");
});
