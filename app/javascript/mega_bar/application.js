// MegaBar Engine JavaScript Entrypoint

import { initializeTabs } from "./tabs.js";
import { initializeLayout } from "./layout.js";

// Initialize when DOM is ready
document.addEventListener("DOMContentLoaded", function () {
  console.log("MegaBar: DOM loaded, initializing modules...");

  initializeTabs();
  console.log("MegaBar: Tabs initialized.");

  initializeLayout();
  console.log("MegaBar: Layout initialized.");
});
