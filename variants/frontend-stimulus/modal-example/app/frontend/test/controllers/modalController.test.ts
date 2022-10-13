import { screen } from '@testing-library/preact';
import { Application } from 'stimulus';
import ModalController from '../../controllers/modal_controller';
import stubWindowLocation from '../stubWindowLocation';

const testHTML = `
  <div data-testid="modal-controller" data-controller="modal" data-modal-close-url="" />
`;

const testHTMLWithCloseURL = `
  <div data-testid="modal-controller" data-controller="modal" data-modal-close-url="/test" />
`;

describe('ModalController', () => {
  beforeEach(() => {
    document.body.innerHTML = testHTML;

    const application = Application.start();

    application.register('modal', ModalController);
  });

  it('navigates to the modal-close-url if provided', () => {
    stubWindowLocation();
    screen
      .getByTestId('modal-controller')
      .dispatchEvent(new CustomEvent('hidden.bs.modal'));
    expect(window.location.pathname).toBe('/');
  });
});

describe('ModalController with close URL', () => {
  beforeEach(() => {
    document.body.innerHTML = testHTMLWithCloseURL;

    const application = Application.start();

    application.register('modal', ModalController);
  });

  it('navigates to the modal-close-url if provided', () => {
    stubWindowLocation();
    screen
      .getByTestId('modal-controller')
      .dispatchEvent(new CustomEvent('hidden.bs.modal'));

    expect(window.location.pathname).toBe('/test');
  });
});
