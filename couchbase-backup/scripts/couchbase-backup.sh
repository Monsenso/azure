#!/bin/bash

# Configure Couchbase backup repository
cluster=${1:-$DEFAULT_CLUSTER}
username=${2:-$DEFAULT_USERNAME}
password=${3:-$DEFAULT_PASSWORD}

backup_month=$(date -dlast-sunday "+%m %Y")
backup_day=$(ncal $backup_month | awk '/Su/ { printf "%02d", $2; exit; }')
repo_name=$(date -dlast-sunday "+%Y.%m.$backup_day")

source $(dirname $BASH_SOURCE[0])'/backup-util.sh'
init_repo $repo_name
delete_old_repos
take_backup $repo_name "$cluster" "$username" "$password"
