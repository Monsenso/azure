#!/bin/bash

if ! type shred &> /dev/null; then
    echo "shred is not installed. If your file system defaults secure deletion then install shred"
    echo "Otherwise comment out below exit 1 and take other security mechanism (e.g. disc encryption)"
    exit 1
fi

if grep --version | grep -q "FreeBSD"; then
    if ! type ggrep &> /dev/null; then
        echo "On macOS install grep via HomeBrew to get the GNU version of grep -> ggrep "
        exit 1
    fi
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
renew_web_service_cert monsenso-eu-prd-kv "*.eu.monsenso.com" $SUB_PRD02

echo =====================================================================
renew_web_service_cert monsenso-eu-dev-kv "*.dev.monsenso.com" $SUB_DEV01

echo =====================================================================
renew_web_service_cert monsenso-eu-tst-kv "*.test.monsenso.com" $SUB_TST01

echo =====================================================================
renew_web_service_cert monsenso-eu-tst-02-kv "*.test-02.monsenso.com" $SUB_TST02

echo =====================================================================
renew_web_service_cert monsenso-uaen-prd-kv "*.uaen.monsenso.com" $SUB_PRD03

echo =====================================================================
renew_couchbase_certificate \
    'Couch11 (OVH PRD)' \
    couch11.eu.private.monsenso.com \
    172.19.20.12

echo =====================================================================
renew_couchbase_certificate \
    'Couch12 (DATA EXTRACT)' \
    couch12.eu.private.monsenso.com \
    172.19.20.27

echo =====================================================================
renew_couchbase_certificate \
    'AU PRD' \
    aue-couchbase.au.private.monsenso.com \
    aue-couchbase.au.private.monsenso.com

echo =====================================================================
renew_couchbase_certificate \
    'EU PRD' \
    weu-couchbase.eu.private.monsenso.com \
    weu-couchbase.eu.private.monsenso.com

echo =====================================================================
renew_couchbase_certificate \
    'EU DEV' \
    weu-dev-couchbase.deveu.private.monsenso.com \
    weu-dev-couchbase.deveu.private.monsenso.com

echo =====================================================================
renew_couchbase_certificate \
    'EU TEST' \
    weu-tst-couchbase.tsteu.private.monsenso.com \
    weu-tst-couchbase.tsteu.private.monsenso.com

echo =====================================================================
renew_couchbase_certificate \
    'UAEN PRD' \
    uaen-prd-couchbase.uaen.private.monsenso.com \
    uaen-prd-couchbase.uaen.private.monsenso.com

echo =====================================================================
renew_couchbase_certificate \
    'EU TEST-02' \
    weu-tst-02-couchbase.tst02eu.private.monsenso.com \
    weu-tst-02-couchbase.tst02eu.private.monsenso.com
