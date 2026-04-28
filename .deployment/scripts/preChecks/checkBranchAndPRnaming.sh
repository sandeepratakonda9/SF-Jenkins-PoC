# Get the pull request title
GITHUB_TOKEN="$1"
GITHUB_NUMBER="$2"


PR_TITLE=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://git.i.mercedes-benz.com/api/v3/repos/mbfs-OneOps/T1224-OneOPS/pulls/$GITHUB_NUMBER | jq -r '.title')

echo "Your current Pull Request title is: " "$PR_TITLE"

# Get the branch name
BRANCH_NAME=$GITHUB_HEAD_REF
echo "Your current Branch name is: " $BRANCH_NAME

# Define the valid team names
VALID_TEAMS=("clientServices" "credit" "devops" "ivr" "retention" "advisory" "dealerMgmt" "oh" "athlon" "collections")

# Define the valid project names
VALID_PROJECT=("ONEOPS" "COP" "COPOQ" "COPACDC" "COPCON" "COPRO" "COPPF" "CHA" "CMPCO" "SAL" "COPAPP" "COPEEE" "OHAI" "OHPF")

# Define the expected formats using regular expressions
EXPECTED_PR_FORMAT="^(\[DO NOT MERGE\]\s*)?($(IFS="|" ; echo "${VALID_TEAMS[*]}"))/($(IFS="|" ; echo "${VALID_PROJECT[*]}"))-[0-9]+\s+[^:]+"
EXPECTED_BRANCH_FORMAT="^($(IFS="|" ; echo "${VALID_TEAMS[*]}"))/($(IFS="|" ; echo "${VALID_PROJECT[*]}"))-[0-9]"

# Check if the pull request title matches the expected format
if [[ ! $PR_TITLE =~ $EXPECTED_PR_FORMAT ]]; then
  echo "error: Pull request title does not match the expected format ([DO NOT MERGE] teamname/JiraProjectKey-1234 SomeTitle)"
  exit 1
else
  echo "Pull request title is in the correct format"
fi

# Check if the branch name matches the expected format
if [[ ! $BRANCH_NAME =~ $EXPECTED_BRANCH_FORMAT ]]; then
  echo "error: Branch name does not match the expected format (teamname/JiraProjectKey-1234)"
  exit 1
else
  echo "Branch name is in the correct format"
fi

exit 0