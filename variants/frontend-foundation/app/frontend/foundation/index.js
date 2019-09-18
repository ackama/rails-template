/* global $ */
import $ from "jquery";
import "./foundation_and_overrides.scss";
import "foundation-sites";

$(document).ready(function () {
  Foundation.MediaQuery._init();
});

$(window).on("load", function () {
  $(document).foundation();
});