import Modal from 'bootstrap/js/dist/modal';
import { Controller } from 'stimulus';

declare global {
  interface DocumentEventMap {
    'turbo:submit-end': TurboEvent;
  }
}

export default class ModalController extends Controller {
  private modal: Modal | undefined;

  public connect(): void {
    this.modal = Modal.getOrCreateInstance(this.element);

    if (this.element.classList.contains('show')) {
      this.modal.show();
    }

    document.addEventListener('turbo:submit-end', this._handleSubmit);
    this.element.addEventListener('hidden.bs.modal', this._navigateOnClose);
  }

  public disconnect(): void {
    this.element.removeEventListener('hidden.bs.modal', this._navigateOnClose);
  }

  protected _close(): void {
    const element = this.element;

    this.modal?.hide();

    element.addEventListener(
      'hidden.bs.modal',
      () => {
        this.modal?.dispose();
      },
      { once: true }
    );
  }

  private readonly _handleSubmit = (e: TurboEvent) => {
    if (e.detail.success) {
      this._close();
    }
  };

  private readonly _navigateOnClose = () => {
    const modal = this.element as HTMLElement;

    // Note that if modalCloseUrl is set, this could override a redirect coming from the server
    if (!modal.dataset.modalCloseUrl) {
      return;
    }
    const closeUrl = new URL(modal.dataset.modalCloseUrl, window.location.href);

    window.location.href = `${window.location.origin}${closeUrl.pathname}${closeUrl.search}${closeUrl.hash}`;
  };
}
