import { Controller } from '@hotwired/stimulus';

// To see this controller in action, add the following to the DOM:
//
//   <div data-controller="hello"></div>

export default class HelloController extends Controller {
  connect() {
    this.element.textContent = 'Hello World!';
  }
}
