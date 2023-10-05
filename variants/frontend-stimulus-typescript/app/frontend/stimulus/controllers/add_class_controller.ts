import { Controller } from '@hotwired/stimulus';

/**
 * This controller adds a CSS class to an element or elements when the action is triggered.
 * It is intentionally very generic, and doesn't prescribe what event should occur for the
 * action to be triggered. Instead, add a `data-action` attribute to your element to determine
 * when to add the class. The class name can be specified with `data-add-class-class-name-value`.
 *
 * See the tests for usage examples.
 */
export default class AddClassController extends Controller<HTMLElement> {
  private declare readonly classNameValue: string;
  private declare readonly classRecipientTargets: HTMLElement[];

  public static values = { className: String };
  public static targets = ['classRecipient'];

  public add(): void {
    for (const target of this.classRecipientTargets) {
      target.classList.add(this.classNameValue);
    }
  }
}
