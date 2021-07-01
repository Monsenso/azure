#!/bin/bash

. "${BASH_SOURCE%/*}/renew_certificate.sh"

renew_couchbase_certificate() {
    local CLUSTER_NAME=$1
    local CERTIFICATE_DOMAIN=$2
    shift
    shift
    NODES=("$@")

    echo "Renewing certificate for nodes in Couchbase cluster $CLUSTER_NAME ($CERTIFICATE_DOMAIN)"

    renew_certificate $CERTIFICATE_DOMAIN SKIPPED
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

    read -p "SSH user for $NODE [$USER]: " COUCHBASE_SSH_USER
    COUCHBASE_SSH_USER=${COUCHBASE_SSH_USER:-$USER}

    openssl rsa -in $ACMESH_HOME/$CERTIFICATE_DOMAIN/$CERTIFICATE_DOMAIN.key > pkey.key 2>/dev/null
    cp $ACMESH_HOME/$CERTIFICATE_DOMAIN/$CERTIFICATE_DOMAIN.cer chain.pem

    read -p "$CLUSTER_NAME Couchbase user: " CB_REST_USERNAME
    read -p "$CLUSTER_NAME Couchbase password: " -s CB_REST_PASSWORD
    echo

    echo "Updating cluster CA"
    docker run --mount type=bind,src=$ACMESH_HOME/$CERTIFICATE_DOMAIN,dst=/mnt \
        monsenso.azurecr.io/couchbase-no-volume:v3 \
            couchbase-cli ssl-manage \
                --cluster "couchbase://${NODES[0]}" \
                --username "$CB_REST_USERNAME" \
                --password "$CB_REST_PASSWORD" \
                --upload-cluster-ca /mnt/ca.cer

    for node in "${NODES[@]}"; do
        echo "Uploading certificate to node $node"
        scp pkey.key chain.pem \
            "$COUCHBASE_SSH_USER"@$node:/opt/couchbase/var/lib/couchbase/inbox
        docker run monsenso.azurecr.io/couchbase-no-volume:v3 \
            couchbase-cli ssl-manage \
                --cluster "couchbase://$node" \
                --username "$CB_REST_USERNAME" \
                --password "$CB_REST_PASSWORD" \
                --set-node-certificate
    done

    if ! type shred &> /dev/null; then
        rm pkey.key chain.pem
    else
        shred -fu pkey.key chain.pem         
    fi    
}
