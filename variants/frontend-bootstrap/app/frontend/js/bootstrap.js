/* eslint-disable no-new */
// import Carousel from 'bootstrap/js/dist/carousel';
import Dropdown from 'bootstrap/js/dist/dropdown';
// import Tab from 'bootstrap/js/dist/tab';
// import Tooltip from 'bootstrap/js/dist/tooltip';

function initializeDropdowns() {
  const dropdownList = Array.from(document.querySelectorAll('.dropdown'));

  dropdownList.forEach(dropdownEl => {
    new Dropdown(dropdownEl);
  });
}

// Uncomment this if you are using carousels
// function initializeCarousels() {
//   const carouselList = Array.from(document.querySelectorAll('.carousel'));

//   carouselList.forEach(carouselEl => {
//     new Carousel(carouselEl);
//   });
// }

// Uncomment this if you are using tabs
// function initializeTabs() {
//   const tabList = Array.from(
//     document.querySelectorAll('[data-bs-toggle="tab"]')
//   );

//   tabList.forEach(tabEl => {
//     new Tab(tabEl);
//   });
// }

// Uncomment this if you are using tooltips
// function initializeTooltips() {
//   const tooltipTriggerList = Array.from(
//     document.querySelectorAll('[data-bs-toggle="tooltip"]')
//   );

//   tooltipTriggerList.forEach(tooltipTriggerEl => {
//     new Tooltip(tooltipTriggerEl);
//   });
// }

['DOMContentLoaded', 'turbo:render', 'turbo:frame-render'].forEach(evt =>
  document.addEventListener(evt, () => {
    initializeDropdowns();
    // initializeCarousels();
    // initializeTabs();
    // initializeTooltips();
  })
);
