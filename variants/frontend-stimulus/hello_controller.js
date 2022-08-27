import { Controller } from '@hotwired/stimulus';

// To see this controller in action, add the following to the DOM:
//
//   <div data-controller="hello"></div>

// eslint-disable-next-line import/no-anonymous-default-export
export default class extends Controller {
  connect() {
    this.element.textContent = 'Hello World!';
  }
}
