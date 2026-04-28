import { LightningElement, api } from 'lwc';

export default class ToggleButtons extends LightningElement {
  @api ignoreWhitespace = false;
  @api ignoreCase = false;

  handleIgnoreWhitespace(event) {
    this.dispatchEvent(new CustomEvent('ignorewhitespaceswitch', { detail: event.target.checked }));
  }

  handleIgnoreCase(event) {
    this.dispatchEvent(new CustomEvent('ignorecaseswitch', { detail: event.target.checked }));
  }
}