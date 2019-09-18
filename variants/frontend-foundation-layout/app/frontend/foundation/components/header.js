import $ from "jquery";

$(window).on("load", function () {
  $(".header").on("down.zf.accordionMenu", function (e) {
    $(".header [data-accordion-menu]").not(e.target).foundation("hideAll");
  });
});