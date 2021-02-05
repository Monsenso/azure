#!/bin/bash

ensure_az_login () {
    if ! az account show &> /dev/null; then
        echo 'Not logged into Azure.'
        echo "Running az login, a browser window will open asking you to sign in."
        az login &> /dev/null
    fi

    if ! az acr show --name monsenso &> /dev/null; then
        echo "Logging in to the Monsenso Azure Container Registry"
        az acr login --name monsenso
    fi
}
