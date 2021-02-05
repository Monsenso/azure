#!/bin/bash

upload_certificate_to_keyvault() {
    local VAULT_NAME=$1
    local CERTIFICATE_NAME=$2
    local FULLCHAIN_PATH=$3
    local KEY_PATH=$4
    local SUBSCRIPTION=$5
    if [ ! -f $FULLCHAIN_PATH ]; then
        echo $FULLCHAIN_PATH not found
        exit 1
    fi

    if [ ! -f $KEY_PATH ]; then
        echo $KEY_PATH not found
        exit 1
    fi

    local days_left_on_cert=$(ssl-cert-check -c "$FULLCHAIN_PATH" -n | grep -oP '(?<=days=)\d*' || echo -1)
    if [ $days_left_on_cert -le 0 ]; then
        echo "$FULLCHAIN_PATH has expired!"
        exit 1
    elif [ $days_left_on_cert -le 20 ]; then
        echo "Only $days_left_on_cert days until $FULLCHAIN_PATH expires!"
        while true; do
            read -p "Upload and use this certificate anyhow? [yes/No] " yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* )
                    exit 1
                    ;;
                '' )
                    exit 1
                    ;;
                * ) echo "Please answer yes or no";;
            esac
    done
    fi

    local pass=$(openssl rand -base64 32)
    openssl pkcs12 -export -inkey "$KEY_PATH" -in "$FULLCHAIN_PATH" -out tmp_cert.pfx \
        -password "pass:$pass"

    az keyvault certificate import \
        --vault-name $VAULT_NAME \
        --name $CERTIFICATE_NAME \
        --file tmp_cert.pfx \
        --password "$pass" \
        ${SUBSCRIPTION:+"--subscription" "$SUBSCRIPTION"} > /dev/null

    shred -fu tmp_cert.pfx
}
