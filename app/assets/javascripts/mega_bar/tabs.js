$(document).ready(function() {
  $(".megaLayoutSectionTabs li").click(function(e) {
    var tabIndex = $(this).index();
    if (!$(this).hasClass("active")) {
      var nthChild = tabIndex + 1;
      $(".megaLayoutSectionTabs li.active").removeClass("active");
      $(this).addClass("active");
      $("#content-tab div.active").removeClass("active");
      $("#content-tab div:nth-child(" + nthChild + ")").addClass("active");
    } else {
      $(this).removeClass("active");
      $("#content-tab div.active").removeClass("active");
    }
  });
});
