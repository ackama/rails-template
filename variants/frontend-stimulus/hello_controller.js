import { Controller } from '@hotwired/stimulus';

// See https://github.com/orgs/stimulus-components/repositories for examples of
// Stimulus controllers. Consider whether it is better for the long term health
// of your app to use these components as a dependency or take some copy & paste
// inspiration.

// To see this controller in action, add the following to the DOM:
//
//   <div data-controller="hello"></div>

// Stimulus docs: https://stimulus.hotwired.dev/
export default class HelloController extends Controller {
  connect() {
    console.log('Hello from the HelloController');
  }
}
