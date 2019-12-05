/* global Foundation */
import $ from 'jquery';
import './foundation_and_overrides.scss';
import 'foundation-sites';

$(document).ready(() => {
  Foundation.MediaQuery._init();
});

$(window).on('load', () => {
  $(document).foundation();
});
