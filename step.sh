#!/bin/bash
set -ex

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.


#GET PR ID

if [ -n "$PULL_REQUEST_ID" ]
then
   #$PULL_REQUEST_ID has value when triggered from PR Update/Open webhook
   echo "Mode = PR Opened/Updated"
   prId=$PULL_REQUEST_ID
   mode="1"
else
   echo "Mode = PR Merged"
   
   latestCommitMessage=`git log -1 --pretty`
   prIdInitialRegex="Pull\srequest\s#[0-9]*:"

   prIdInitial=`echo $latestCommitMessage | { grep $prIdInitialRegex -o || true; }`
   prId=`echo $prIdInitial | tr -dc [0-9]`
   mode="2"
fi


if [ -z "$prId" ]
then
   echo "Could not parse PR ID; most likely commit is not PR merge commit or PR open/update"
   exit 1
else

  #GET JIRA TICKETS

  ticketRegex="${jira_project_key}-[0-9]*"

  url="https://$bitbucket_baseurl/rest/api/1.0/projects/$bitbucket_project/repos/$bitbucket_repo/pull-requests/$prId"

  #https://developer.atlassian.com/cloud/bitbucket/rest/api-group-pullrequests/#api-repositories-workspace-repo-slug-pullrequests-pull-request-id-get
  prDetails=`curl --request GET \
    --url "${url}" \
    --header "Authorization: Bearer ${git_access_token}" \
    --header 'Accept: application/json'`

  prTitle=`echo $prDetails | jq -r .title`
  prSourceBranch=`echo $prDetails | jq -r .fromRef.displayId`
  prTargetBranch=`echo $prDetails | jq -r .toRef.displayId`

  #/diff and /commits have different behavior, but /commits are exactly what we see on bitbucket PR commits
  prDetailsDiff=`curl --request GET \
    --url "${url}/commits" \
    --header "Authorization: Bearer ${git_access_token}" \
    --header 'Accept: application/json'`

  includedCommitMessages=`echo $prDetailsDiff | jq -r .values[].message`


  jiraTicketsFromTitle=`echo $prTitle | { grep $ticketRegex -o || true; }`
  jiraTicketsFromBranchName=`echo $prSourceBranch | { grep $ticketRegex -o || true; }`
  jiraTicketsFromCommits=`echo $includedCommitMessages | { grep $ticketRegex -o || true; }`


  #set outputs

  if [ -n "$jiraTicketsFromTitle" ]
  then
    envman add --key JIRA_TICKETS_FROM_TITLE --value "$jiraTicketsFromTitle"
  fi
  
  if [ -n "$jiraTicketsFromBranchName" ]
  then
    envman add --key JIRA_TICKETS_FROM_BRANCH_NAME --value "$jiraTicketsFromBranchName"
  fi
  
  if [ -n "$jiraTicketsFromCommits" ]
  then
    envman add --key JIRA_TICKETS_FROM_COMMITS --value "$jiraTicketsFromCommits"
  fi
  
  envman add --key JIRA_PARSER_MODE --value $mode
  envman add --key PR_TARGET_BRANCH --value $prTargetBranch
  
fi



