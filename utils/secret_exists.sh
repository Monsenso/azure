#!/bin/bash

secret_exists () {
    VAULT_NAME=$1
    SECRET_NAME=$2

    az keyvault secret show --vault-name $VAULT_NAME --name $SECRET_NAME  >/dev/null 2>&1
    return $?
}
