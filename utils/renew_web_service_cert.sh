#!/bin/bash

. "${BASH_SOURCE%/*}/renew_certificate.sh"
. "${BASH_SOURCE%/*}/upload_certificate_to_keyvault.sh"

renew_web_service_cert() {
    local ACMESH_HOME=${ACMESH_HOME:-~/.acme.sh}
    local VAULT=$1
    local DOMAIN=$2
    local SUBSCRIPTION=$3

    echo "Renewing $DOMAIN certificate"

    renew_certificate $DOMAIN SKIPPED
    if [ $SKIPPED ]; then
        while true; do
            read -p "Do you want to upload the current certificate? [yes/No] " yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* )
                    return
                    ;;
                '' )
                    return
                    ;;
                * ) echo "Please answer yes or no";;
            esac
        done
    fi

    upload_certificate_to_keyvault \
        $VAULT \
        web-service-cert \
        "$ACMESH_HOME/$DOMAIN/fullchain.cer" \
        "$ACMESH_HOME/$DOMAIN/$DOMAIN.key" \
        "$SUBSCRIPTION"

    echo "web-service-cert updated, it'll take up to 48 hours for the App Services to use the `
         `new certificate. It is possible to manually sync the certificate for each App `
         `Service: "TLS/SSL settings" > "Private Key Certificates \(.pfx\)" > click on the `
         `private key certificate > click sync"
}
