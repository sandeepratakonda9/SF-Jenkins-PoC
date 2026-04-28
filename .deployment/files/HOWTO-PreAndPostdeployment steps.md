# How to use this folder

* We are not using  .deployment/pre-deployment-steps.md / .deployment/post-deployment-steps.md anymore! 
* Any manual steps should be stored under .deployment/files
    * here open the folder of your project
        * open either pre-deployment or post-deployment
        * Always create 
            1. a new folder named as your ticket
            2. a .txt file and name it after the respective jira ticket
            3. in Case a e.g. csv file has to be stored with it, name it also after the ticket + give it a meaningful title
            * examples: 
            * ONEOPS-1234.txt.
            * ONEOPS-1234_ListOfUsersToBeUpdated.csv.
        * In case the file is used to a Decision Matrix: 
            * Create a .csv named like the Decision Matrix and store it under the pre-deployment or post-deployment folder directly OR
            * Update the existing file of the respective Decision Matrix, in case it exists already


## Example for such .txt file
filename: ONEOPS-1234.txt or COP-1234.txt etc

Steps:
1. Go to Setup -> OmniStudio Settings
2. Disable "Managed Package Runtime"
3. If "Deploy Custom Lightning Web Components in Standard Runtime" is present in the org, disable it.

Applicable orgs : PreProd, Production
