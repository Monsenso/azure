#!/bin/bash

set_secret () {
    local VAULT_NAME=$1
    local SECRET_NAME=$2
    local SECRET_VALUE=$3

    az keyvault secret set --name "$SECRET_NAME" \
        --vault-name $VAULT_NAME \
        --value "$SECRET_VALUE" \
        --tags "" > /dev/null
}
