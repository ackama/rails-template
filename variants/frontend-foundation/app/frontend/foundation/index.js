/* global $ */
import "jquery";
import "./application.scss";
import "foundation-sites";

$(document).ready(function () {
  Foundation.MediaQuery._init();
});

$(window).on("load", function () {
  $(document).foundation();
});