import { LightningElement, api } from 'lwc';

export default class UserBasicInfo extends LightningElement {
    @api user;
    @api profile;
    @api role;
}