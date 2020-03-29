import $ from 'jquery';

$(window).on('load', () => {
  $('.header').on('down.zf.accordionMenu', e => {
    $('.header [data-accordion-menu]').not(e.target).foundation('hideAll');
  });
});
