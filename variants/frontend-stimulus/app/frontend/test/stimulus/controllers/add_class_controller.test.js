import { Application } from '@hotwired/stimulus';
import AddClassController from '../../../stimulus/controllers/add_class_controller';

const testHTML = `
  <div data-controller="add-class" data-add-class-class-name-value="test-class">
    <button id="button" data-action="add-class#add">Click to add class!</button>
    <div data-add-class-target="classRecipient" id="el1"></div>
    <div data-add-class-target="classRecipient" id="el2"></div>
  </div>
`;

describe('AddClassController', () => {
  beforeEach(() => {
    document.body.innerHTML = testHTML;

    const application = Application.start();

    application.register('add-class', AddClassController);
  });

  it('adds the classes to the target elements when the action is triggered', () => {
    document.getElementById('button')?.click();

    expect(document.getElementById('el1')).toHaveClass('test-class');
    expect(document.getElementById('el2')).toHaveClass('test-class');
  });
});
