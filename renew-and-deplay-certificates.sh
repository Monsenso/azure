#!/bin/bash

if ! type shred &> /dev/null; then
    echo "shred is not installed."
    exit 1
fi

if ! type openssl &> /dev/null; then
    echo "openssl is not installed."
    exit 1
fi

if ! type ssl-cert-check &> /dev/null; then
    echo "ssl-cert-check is not installed."
    exit 1
fi

. "${BASH_SOURCE%/*}/utils/ensure_az_login.sh"
. "${BASH_SOURCE%/*}/utils/renew_web_service_cert.sh"
. "${BASH_SOURCE%/*}/utils/renew_couchbase_certificate.sh"
. "${BASH_SOURCE%/*}/utils/subscriptions.env"

ensure_az_login

ACMESH_HOME=${ACMESH_HOME:-~/.acme.sh}
if [ ! -d $ACMESH_HOME ]; then
    echo "acme.sh not found. Set ACMESH_HOME to the path for the acme.sh directory"
    exit 1
fi


echo =====================================================================
renew_web_service_cert monsenso-au-prd-kv "*.au.monsenso.com" $SUB_PRD01

echo =====================================================================
renew_couchbase_certificate \
    'Couch11 (OVH PRD)' \
    couch11.eu.private.monsenso.com \
    172.19.20.12

echo =====================================================================
renew_couchbase_certificate \
    'AU PRD' \
    aue-couchbase.au.private.monsenso.com \
    aue-couchbase.au.private.monsenso.com
