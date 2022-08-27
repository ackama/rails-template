import { Controller } from '@hotwired/stimulus';

// eslint-disable-next-line import/no-anonymous-default-export
export default class extends Controller {
  connect() {
    this.element.textContent = 'Hello World!';
  }
}
