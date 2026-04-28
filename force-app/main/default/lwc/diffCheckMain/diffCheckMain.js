import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import diffLibrary from '@salesforce/resourceUrl/diff';
import lodashLibrary from '@salesforce/resourceUrl/lodash';

export default class DiffCheckMain extends LightningElement {
  @track inputText1 = '';
  @track inputText2 = '';
  @track ignoreWhitespace = false;
  @track ignoreCase = false;
  @track summary = '';

  async connectedCallback() {
    await Promise.all([
      loadScript(this, lodashLibrary),
      loadScript(this, diffLibrary)
    ]);
  }

  handleInput1(event) {
    this.inputText1 = event.target.value;
  }

  handleInput2(event) {
    this.inputText2 = event.target.value;
  }

  handleIgnoreWhitespace(event) {
    this.ignoreWhitespace = event.detail;
  }

  handleIgnoreCase(event) {
    this.ignoreCase = event.detail;
  }

  async handleCompare() {
    const differences = await this.compareText(this.inputText1, this.inputText2);
    this.summary = differences.length > 0 ? differences.join('\n') : 'No differences found';
  }

  async compareText(text1, text2) {
    const diff = window.diff;
    const _ = window.lodash;

    const differences = [];

    // Compare text
    const comparison = diff.diffLines(text1, text2);
    comparison.forEach((part) => {
      const { value, added, removed } = part;

      if (!this.ignoreWhitespace || value.trim() !== '') {
        const line = value.trim();

        if (added) {
          differences.push(`+ ${line}`);
        } else if (removed) {
          differences.push(`- ${line}`);
        } else {
          differences.push(`  ${line}`);
        }
      }
    });

    // Compare JSON
    try {
      const json1 = JSON.parse(text1);
      const json2 = JSON.parse(text2);

      const jsonDiff = diff.diff(json1, json2);
      jsonDiff.forEach((part) => {
        const { value, added, removed } = part;
        const line = JSON.stringify(value, null, 2);

        if (added) {
          differences.push(`+ ${line}`);
        } else if (removed) {
          differences.push(`- ${line}`);
        } else {
          differences.push(`  ${line}`);
        }
      });
    } catch (error) {
      // Handle JSON parsing error if needed
    }

    return differences;
  }

  handleReset() {
    this.inputText1 = '';
    this.inputText2 = '';
    this.summary = '';
  }

  handleStartNewDiff() {
    this.inputText1 = '';
    this.inputText2 = '';
    this.summary = '';
    this.ignoreWhitespace = false;
    this.ignoreCase = false;
  }
}