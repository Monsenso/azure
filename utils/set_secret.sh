#!/bin/bash

set_secret () {
    VAULT_NAME=$1
    SECRET_NAME=$2
    SECRET_VALUE=$3

    az keyvault secret set --name "$SECRET_NAME" \
        --vault-name $VAULT_NAME \
        --value "$SECRET_VALUE" \
        --tags "" > /dev/null
}