import { LightningElement, api } from 'lwc';

export default class Button extends LightningElement {
  @api label;
  @api disabled = false;

  handleClick() {
    this.dispatchEvent(new CustomEvent('click'));
  }
}