import { Application } from '@hotwired/stimulus';
import { screen } from '@testing-library/dom';
import userEvent from '@testing-library/user-event';
import AddClassController from '../../../stimulus/controllers/add_class_controller';

const testHTML = `
  <div data-controller="add-class" data-add-class-class-name-value="test-class">
    <button data-action="add-class#add">Click to add class!</button>
    <div data-add-class-target="classRecipient">div one</div>
    <div data-add-class-target="classRecipient">div two</div>
  </div>
`;

describe('AddClassController', () => {
  beforeEach(() => {
    document.body.innerHTML = testHTML;

    const application = Application.start();

    application.register('add-class', AddClassController);
  });

  it('adds the classes to the target elements when the action is triggered', async () => {
    const user = userEvent.setup();

    await user.click(screen.getByRole('button'));

    expect(screen.getByText('div one')).toHaveClass('test-class');
    expect(screen.getByText('div two')).toHaveClass('test-class');
  });
});
