#!/bin/bash

# Requires jq and azure-cli

if ! type jq &> /dev/null; then
    echo "jq is not installed."
    exit 1
fi

if ! type az &> /dev/null; then
    echo "Azure CLI is not installed."
    exit 1
fi

if [ "$SERVING_REGION" == "" ]; then
    echo "SERVING_REGION is not set. This must be set to the region the environment is serving."
    echo "E.g. eu, au, us"
    exit 1
fi

if [ "$DEPL_REGION" == "" ]; then
    echo "DEPL_REGION is not set. This must be set to the azure region our service are deployed
    to."
    echo "E.g. aue, euw, use"
    exit 1
fi

if [ "$ENV" == "" ]; then
    echo "ENV is not set. This must be set to the environment being deployed."
    echo "I.e. prd, beta, test, dev"
    exit 1
fi

subscriptionName=$(az account list --query '[?isDefault].name' | jq -r '.[0]')
while true; do
    read -p "Use subscription $subscriptionName? [yes/No] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* )
            echo "use 'az account set --subscription <subscription id>' to change subscription"
            echo "use 'az account list --output table' to show a list of available subscriptions"
            exit
            ;;
        '' )
            echo "use 'az account set --subscription <subscription id>' to change subscription"
            echo "use 'az account list --output table' to show a list of available subscriptions"
            exit
            ;;
        * ) echo "Please answer yes or no";;
    esac
done

. utils/secret_exists.sh
. utils/set_secret.sh
. utils/ensure_az_login.sh

ensuze_az_login

VAULT_NAME=monsenso-$SERVING_REGION-$ENV-kv
for f in secrets/*
do
    secret_name=$(basename $f)
    if secret_exists $VAULT_NAME $secret_name; then
        echo "The $secret_name already exists; SKIPPING."
    else
        secret_value=$(bash $f)

        if [ "$secret_value" == "" ];
        then
            echo "Value for $secret_name evaluated to empty; SKIPPING."
        else
            echo "Setting $secret_name secret"
            set_secret $VAULT_NAME $secret_name $secret_value
        fi
    fi
done

echo "Done"
