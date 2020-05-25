#!/bin/bash

ARCHIVE=/datadisk/couchbase-backup
THREADS=$(grep -c processor /proc/cpuinfo)
CBBACKUPMGR=/opt/couchbase/bin/cbbackupmgr

log() {
    timestamp=$(date +%FT%T.%7N%z)
    today=$(date +%Y.%m.%d)
    level=$1
    message=$2
    elapsed=$3
    repo=$([ -z "$4"] && echo "$repo_name" || echo "$4")

    # JSON=$(jo -p \
    #     @timestamp=$timestamp \
    #     level=$level \
    #     message="$message" \
    #     messageTemplate="$message" \
    #     fields[Service]="Couchbase Backup" \
    #     fields[BackupRepository]=$repo \
    #     fields[Elapsed]=$elapsed \
    #     fields[Cluster]=$CLUSTER)

    echo $message
}

init_repo() {
    repo_name=$1

    starttime=$(date +%s%9N)
    $CBBACKUPMGR list --archive $ARCHIVE --repo $repo_name
    if [ ! $? -eq 0 ]
    then
        $CBBACKUPMGR config --archive $ARCHIVE --repo $repo_name --disable-eventing
        cmd_exit_code=$?

        elapsed=$(jq -n $(($(date +%s%9N) - $starttime))/1000000000)
        if [ $cmd_exit_code -eq 0 ]
        then
            log Information "Backup repo $repo_name configured" $elapsed
        else
            msg=("Failed to configure the $repo_name repo,"
                "cbbackupmgr exit code: $cmd_exit_code")
            log Error "${msg[*]}" $elapsed
            exit 1
        fi
    fi
}

delete_old_repos() {
    # Delete repository older than 6 months (We must always have backup
    # from the last 6 months).
    repos=($($CBBACKUPMGR list --archive $ARCHIVE \
        | grep -oP '\d{4}\.\d\d\.\d\d'))
    repo_count=${#repos[@]}

    if [ $repo_count -gt 7 ]; then
        oldest_repo=${repos[0]}
        $CBBACKUPMGR remove --archive $ARCHIVE --repo $oldest_repo
        cmd_exit_code=$?
        if [ $cmd_exit_code -eq 0 ]
        then
            log Information "Backup repository removed" $elapsed $oldest_repo
        else
            log Error "Failed to remove backup repository, cbbackupmgr exit code: $cmd_exit_code" $elapsed $oldest_repo
        fi
    fi
}

take_backup() {
    repo_name=$1
    cluster=$2
    username=$3
    password=$4

    echo "Backing up $cluster"
    $CBBACKUPMGR backup \
        --archive $ARCHIVE \
        --repo $repo_name \
        --cluster "$cluster" \
        --username "$username" \
        --password "$password" \
        --threads $THREADS \
        --purge \
        --no-progress-bar
    cmd_exit_code=$?

    elapsed=$(jq -n $(($(date +%s%9N) - $starttime))/1000000000)
    if [ $cmd_exit_code -eq 0 ]
    then
        log Information "Backup completed" $elapsed
    else
        log Error "Failed to take backup, cbbackupmgr exit code: $cmd_exit_code" $elapsed
        exit 2
    fi
}
