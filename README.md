# Pull Request JIRA Ticket Parser

Parses related Jira tickets for a Pull Request

## Requirements
1) JQ is installed via homebrew before this step is called

2) Pull Requests declare which jira tickets are related via: 


   A) PR Title (e.g [Tech improvement][RFMI-1410]: TabBarController unit test)

   B) Commit messages (e.g RFMA-1538 [Tech Improvement] Rich Push Notification Unit Test)

   C) Source branch name (e.g feature/RFMI-12345-lorem-ipsum)

3) Repository is hosted on Bitbucket server/cloud (this step uses bitbucket rest api)\n

## Outputs


  
  1) PR_TARGET_BRANCH (e.g develop, release/X.X.X)
  
  
  2) JIRA_PARSER_MODE


    value can be: "1" or "2" or null
  
  
       - PR opened/updated (i.e "1")
  
  
       - PR merged (i.e "2")
  

  3) JIRA_TICKETS_FROM_TITLE
  
  
  4) JIRA_TICKETS_FROM_BRANCH_NAME
  
  
  5) JIRA_TICKETS_FROM_COMMITS

    value can be:
  
       - Single Value (e.g RFMI-1234)
  
       - Multiple value [comma delimited] (e.g RFMI-1244,RFMI-5589)
  
       - No value [null]
  
  
  
  

## How to use this Step
Add step on your CI and provide value for all input fields below
```
- git::https://github.com/joshuafrancisrak/pull_request_ticket_parser.git@master:
        title: PR Jira ticket parser
        is_skippable: true
        inputs:
        - bitbucket_baseurl: git.mydomain.com
        - bitbucket_project: RFM
        - bitbucket_repo: my-repository-name
        - git_access_token: "$GIT_ACCESS_TOKEN"
        - jira_project_key: RFMI
        is_always_run: true
```
