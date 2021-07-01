#!/bin/bash

renew_certificate() {
    ACMESH_HOME=${ACMESH_HOME:-~/.acme.sh}
    DOMAIN=$1
    __SKIPPED=$2

    if grep --version | grep -q "FreeBSD"; then
        if ! type ggrep &> /dev/null; then
            echo "On macOS install grep via HomeBrew to get the GNU version of grep -> ggrep "
            exit 1
        fi
    fi

    CERT_PATH=$ACMESH_HOME/$DOMAIN/$DOMAIN.cer
    if ! type ggrep &> /dev/null; then #Homebrew macOS prefix 'g' for grep
        days_left_on_cert=$(ssl-cert-check -c "$CERT_PATH" -n | grep -oP '(?<=days=)\d*' || echo -1)
    else
        days_left_on_cert=$(ssl-cert-check -c "$CERT_PATH" -n | ggrep -oP '(?<=days=)\d*' || echo -1)        
    fi
    if [ $days_left_on_cert -ge 31 ]; then
        echo "There are $days_left_on_cert days until expiry; NOT renewing"
        if [[ "$__SKIPPED" ]]; then
            eval $__SKIPPED=0
        fi
    else
        (
            cd $ACMESH_HOME
            ./acme.sh --renew -d "$DOMAIN"
        )
        if [[ "$__SKIPPED" ]]; then
            eval $__SKIPPED=1
        fi
    fi
}
