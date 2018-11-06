#!/usr/bin/env bash

# Check bash version
VERSION=`bash --version|head -1|cut -d' ' -f 4`
if [[ $VERSION != 4* ]]
then
  echo "As this script uses associative arrays, it requireds bash v4"
  echo "you are running bash $VERSION"
  exit 1
fi

TOKEN=JLykHVWlgcpdIa07y2KrVEpH
VAULT_ADDR="https://127.0.0.1:8200"
#
# # Set up 3 namespaces
curl -k \
    --header "X-Vault-Token: ${TOKEN}" \
    --request POST \
    ${VAULT_ADDR}/v1/sys/namespaces/avengers

curl -k \
    --header "X-Vault-Token: ${TOKEN}" \
    --request POST \
    ${VAULT_ADDR}/v1/sys/namespaces/Justice-League

curl -k \
    --header "X-Vault-Token: ${TOKEN}" \
    --request POST \
    ${VAULT_ADDR}/v1/sys/namespaces/X-Men

# Add userpass auth method at /userpass
# and get the userpass accessor value
curl -k \
    --header "X-Vault-Token: ${TOKEN}" \
    --request POST \
    --data '{"type": "userpass", "description": "General Auth Method"}' \
    ${VAULT_ADDR}/v1/sys/auth/userpass

UP_ACC=`curl -k --silent --header "X-Vault-Token: ${TOKEN}" ${VAULT_ADDR}/v1/sys/auth | jq -r '.["userpass/"].accessor'`

# Declare the Users
declare -A users=(
  ["Captain_America"]="Steve Rogers"
  ["Iron_Man"]="Tony Stark"
  ["Thor"]="Donald Blake"
  ["Black_Widow"]="Natasha Romanova"
  ["Wolverine"]="James Howlett"
  ["Cyclops"]="Scott Summers"
  ["Storm"]="Ororo Munroe"
  ["Angel"]="Warren Worthington III"
)
declare -a Avengers=(
  "Captain_America"
  "Iron_Man"
  "Thor"
  "Black_Widow"
)
declare -a XMen=(
  "Wolverine"
  "Cyclops"
  "Storm"
  "Angel"
)

for u in "${!users[@]}"
do
# Create user (will become the alias to the entity)
  curl -k --silent \
        --header "X-Vault-Token: ${TOKEN}" \
        --request POST \
        --data  '{"password": "my_pass"}' \
        ${VAULT_ADDR}/v1/auth/userpass/users/${u}
# Create entity and get entity id (real name)
  ENT_ID=`curl -k --silent \
        --header "X-Vault-Token: ${TOKEN}" \
        --request POST \
        --data "{\"name\": \"${users[$u]}\"}" \
        ${VAULT_ADDR}/v1/identity/entity | jq -r '.data.id'`
  if [[ "${Avengers[@]}" =~ $u ]]
  then
    if [ "${avenger_id}X" == "X" ]
    then
      avenger_id="\"${ENT_ID}\""
    else
      avenger_id="${avenger_id}, \"${ENT_ID}\""
    fi
  elif [[ "${XMen[@]}" =~ $u ]]
  then
    if [ "${xmen_id}X" == "X" ]
    then
      xmen_id="\"${ENT_ID}\""
    else
      xmen_id="${xmen_id}, \"${ENT_ID}\""
    fi
  fi

# Now add the user to the entity
  curl -k --silent \
        --header "X-Vault-Token: ${TOKEN}" \
        --request POST \
        --data  "{\"name\": \"${u}\", \"canonical_id\": \"${ENT_ID}\", \"mount_accessor\": \"${UP_ACC}\"}" \
        ${VAULT_ADDR}/v1/identity/entity-alias
done
echo "{\"name\": \"Avengers\", \"member_entity_ids\": [${avenger_id}]}"
echo "{\"name\": \"XMen\", \"member_entity_ids\": [${xmen_id}]}"
# Create the group for each set of entities
curl -k --silent \
      --header "X-Vault-Token: ${TOKEN}" \
      --request POST \
      --data "{\"name\": \"Avengers\", \"member_entity_ids\": [${avenger_id}]}" \
      ${VAULT_ADDR}/v1/identity/group

curl -k --silent \
      --header "X-Vault-Token: ${TOKEN}" \
      --request POST \
      --data "{\"name\": \"XMen\", \"member_entity_ids\": [${xmen_id}]}" \
      ${VAULT_ADDR}/v1/identity/group

echo ${avenger_id}
echo ${xmen_id}
