import { LightningElement, api } from 'lwc';

export default class TextArea extends LightningElement {
  @api label;
  @api value1;
  @api value2;

  handleInput1(event) {
    this.dispatchEvent(new CustomEvent('input1', { detail: event.target.value }));
  }

  handleInput2(event) {
    this.dispatchEvent(new CustomEvent('input2', { detail: event.target.value }));
  }
}