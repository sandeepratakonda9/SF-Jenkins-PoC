## Checklist - please review and *always* answer these questions!

Please go over this list after the creation of the PR:

- [ ] Are no merge conflicts present? If there are, please use `git merge origin/develop` to resolve these first.
- [ ] Were the automated checks successful? If not - check any errors first! 
- [ ] Is the Acceptance Criteria of the Jira ticket met?
- [ ] Was the functionality tested successful locally?
- [ ] Is newly created metadata stored in the correct directories? 
    - Please ask yourself: could e.g. a field be relevant for just your team or useful globally? If the latter, consider moving it to FS_ or even CORE_ folders with respective prefix
    - When in doubt please align with your team's architect
    - For new metadata also refer to https://developer.salesforce.com/docs/metadata-coverage/62
- [ ] Are all naming conventions considered and aligned with existing metadata?
- [ ] If new fields/flows/apex classes got created, are all permissions present incl. profiles?
- [ ] If new record-triggered flows got created, is an Apex test class created / existing one enhanced?
- [ ] If any: are required Pre- & Post-Deployment steps added to respective documents in the correct folders?
- [ ] Is any Documentation in Confluence updated accordingly?
- [ ] Is anything relevant to Arch sync approval part of this user story? In scope for Arch Sync approval are: new custom objects, new custom code / UI (APEX/LWC - Test classes are NOT in scope here!), custom endpoints, etc.
    - [ ] NO - no such changes as part of this PR / User story. 
    - [ ] YES - there are such changes AND they are approved by Arch sync. 
    PLEASE provide the confluence link to the Arch sync decision page where the approval is documented in the comments of the PR! 

## Remarks

{quick overview in few bullet points of PR}

## Dependencies

{provide detailed information, if any, Example: please deploy ticket-1234 first}

