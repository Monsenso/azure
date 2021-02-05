#!/bin/bash

secret_exists () {
    local VAULT_NAME=$1
    local SECRET_NAME=$2

    az keyvault secret show --vault-name $VAULT_NAME --name $SECRET_NAME  >/dev/null 2>&1
    return $?
}
