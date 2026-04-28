/*
 * @description       : Script to enable Omnistudio Metadata setting
 * @param             : LOGIN_URL = $(sf org open -o "$ORG_ALIAS" --url-only --json | jq -r '.result.url')
 * @usage             : node .deployment/scripts/orgManagement/enableOmniSudioSettings.js "$LOGIN_URL"
 */
const puppeteer = require('puppeteer');

(async () => {  
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();
  try{
    
    // Step 1: Salesforce Scratch Org Login
    const loginUrl = process.argv[2];
    await page.goto(loginUrl, { waitUntil: 'networkidle2' });
    await page.waitForNavigation({ waitUntil: 'networkidle2' });

    // Step 2: Open Salesforce Setup
    const urlObj = new URL(loginUrl);
    const baseUrl = urlObj.origin;
    const omniStudioSettings = baseUrl + '/lightning/setup/OmniStudioSettings/home';
    await page.goto(omniStudioSettings, { waitUntil: 'networkidle2' });

    // Step 3: Enable OmniStudio Metadata setting
    await page.waitForSelector('input[type="checkbox"][name="toggle-OmniStudioMetadata"]:not([disabled])', { visible: true });
    const checkbox = await page.$('input[type="checkbox"][name="toggle-OmniStudioMetadata"]');
    const isChecked = await (await checkbox.getProperty('checked')).jsonValue();   
    if (!isChecked) {
      await page.evaluate(el => el.scrollIntoView({ behavior: 'smooth', block: 'center' }), checkbox);
      await page.evaluate(el => el.click(), checkbox);
      // Confirmation modal appears
      const modalSelector = 'section.slds-modal[role="alertdialog"]';
      await page.waitForSelector(modalSelector, { visible: true });
      // Click the OK button in the modal
      const okButtonSelector = 'section.slds-modal[role="alertdialog"] button[data-ok-button]';
      await page.waitForSelector(okButtonSelector, { visible: true });
      await page.click(okButtonSelector);
    }
  } catch (error) {
    console.error('Error enabling the Omnistudion Metadata settings : ', error);
} finally {
    // Close the browser
    await browser.close();
}
})();