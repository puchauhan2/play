#!/bin/bash
rm -rf /tmp/github_code/
mkdir -p /tmp/github_code/
echo "Setting variables"
export GITHUB_TOKEN="$3"
export REPO_URL="$1"
export BRANCH_NAME="$6"
export ACCOUNT_NEW_LINES="$7"
export GITHUB_API_BASE_URL="$2"
export ACCOUNT_NAME="$5"
export ACCOUNT_REQUEST_ID="$4"
trap "echo error occured" ERR EXIT

echo "##################################################################"
cd /tmp/github_code/
git clone https://${GITHUB_TOKEN}@${REPO_URL} .
#cd jenkins_lambda
git config user.email "accountvendingautomation@github.com"
git config user.name "Account Vending Automation"

sleep 0.01
git checkout -b ${BRANCH_NAME}
echo "Appending new account details to accounts-config.yaml"
echo "${ACCOUNT_NEW_LINES}" >> accounts-config.yaml
git add accounts-config.yaml
git commit -m "Appended new account details"


echo "***********************************************************"
git push https://${GITHUB_TOKEN}@${REPO_URL} ${BRANCH_NAME}
gh pr create --title " ${ACCOUNT_NAME} " --body "Account Request ID - ${ACCOUNT_REQUEST_ID}, Account Name - ${ACCOUNT_NAME} " --base main --head "${BRANCH_NAME}"  2>&1 | tee /tmp/result
pull_request_url=`cat /tmp/result | grep https`
echo ${pull_request_url}
pull_request_number="${pull_request_url##*/}"
echo ${pull_request_number}
BASE_BRANCH="main"
PR_BRANCH=${BRANCH_NAME}
PR_NUMBER=${pull_request_number}

#sleep 20
git fetch origin
git checkout $BASE_BRANCH
git pull origin $BASE_BRANCH

if git merge --no-commit --no-ff $PR_BRANCH; 
then
echo "No conflicts detected. Ready to merge.";     
git merge --abort; 
else     
echo "Conflicts detected. Please resolve conflicts before merging."; 
git merge --abort; 
echo "Reverting commit in main branch"    
git checkout $BASE_BRANCH
git revert HEAD
git push origin $BASE_BRANCH

fi

echo "Approving pull request and Merging changes"
gh pr review $PR_NUMBER --approve
gh pr merge $PR_NUMBER --merge