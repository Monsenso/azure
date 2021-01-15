#!/bin/bash

# Requires jq and azure-cli

. utils/secret_exists.sh
. utils/set_secret.sh

export SERVING_REGION=au
export DEPL_REGION=aue
export ENV=prd

# az login

VAULT_NAME=monsenso-$SERVING_REGION-$ENV-kv
for f in secrets/*
do
    secret_name=$(basename $f)
    if ! secret_exists $VAULT_NAME $secret_name; then
    # if [ $secret_name = "systemFunctionsStorageConnectionString" ]; then
        secret_value=$(bash $f)

        set_secret $VAULT_NAME $secret_name $secret_value

        echo "Secret $secret_name set"
    fi
done