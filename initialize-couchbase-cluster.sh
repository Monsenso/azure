NODE_FQDN=${NODE_FQDN:-localhost}
ADMIN_USERNAME=${ADMIN_USERNAME:-Administrator}
CLUSTER_RAMSIZE=${CLUSTER_RAMSIZE:-20480}
INDEX_RAMSIZE=${INDEX_RAMSIZE:-4096}
AUTH_BUCKET_RAMSIZE=${AUTH_BUCKET_RAMSIZE:-1024}
DATA_BUCKET_RAMSIZE=${DATA_BUCKET_RAMSIZE:-10240}
SYSTEM_BUCKET_RAMSIZE=${SYSTEM_BUCKET_RAMSIZE:-1024}
GLOBAL_BUCKET_RAMSIZE=${GLOBAL_BUCKET_RAMSIZE:-1024}

check_db() {
  curl --silent http://$NODE_FQDN:8091/pools > /dev/null
  echo $?
}

echo Settings:
echo "  NODE_FQDN: $NODE_FQDN"
echo "  ADMIN_USERNAME: $ADMIN_USERNAME"
echo "  CLUSTER_RAMSIZE: $CLUSTER_RAMSIZE"
echo "  INDEX_RAMSIZE: $INDEX_RAMSIZE"
echo "  AUTH_BUCKET_RAMSIZE: $AUTH_BUCKET_RAMSIZE"
echo "  DATA_BUCKET_RAMSIZE: $DATA_BUCKET_RAMSIZE"
echo "  SYSTEM_BUCKET_RAMSIZE: $SYSTEM_BUCKET_RAMSIZE"
echo "  GLOBAL_BUCKET_RAMSIZE: $GLOBAL_BUCKET_RAMSIZE"
while true; do
    read -p 'Are these correct? [yes/No] ' yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        '' ) exit;;
        * ) echo "Please answer yes or no";;
    esac
done

stty -echo
printf "Admin password: "
read ADMIN_PASSWORD
stty echo

echo "Waiting for Couchbase to respond"
until [[ $(check_db) = 0 ]]; do
  sleep 1
done

export PATH=$PATH:/opt/couchbase/bin

# Initialize cluster
echo "Initializing cluster"
couchbase-cli cluster-init \
    --cluster-username=$ADMIN_USERNAME \
    --cluster-password=$ADMIN_PASSWORD \
    --cluster-port=8091 \
    --cluster-ramsize=$CLUSTER_RAMSIZE \
    --cluster-index-ramsize=$INDEX_RAMSIZE \
    --services=data,index,query,fts

couchbase-cli setting-security \
    --cluster couchabse://localhost \
    --username $ADMIN_USERNAME \
    --password $ADMIN_PASSWORD \
    --tls-min-version tlsv1.2 \
    --tsl-honor-cipher-order 1 \
    --cipher-suites TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,`
                    `TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA

# Upload cluster CA
echo "Uploading Let’s Encrypt R3 as cluster CA"
wget https://letsencrypt.org/certs/lets-encrypt-r3.pem
couchbase-cli ssl-manage \
    --cluster couchbase://localhost \
    --username $ADMIN_USERNAME \
    --password $ADMIN_PASSWORD \
    --upload-cluster-ca ./lets-encrypt-r3.pem

mkdir -p /opt/couchbase/var/lib/couchbase/inbox
chown couchbase:couchbase /opt/couchbase/var/lib/couchbase/inbox
chmod 733 /opt/couchbase/var/lib/couchbase/inbox

# Create buckets
echo "Creating auth bucket"
couchbase-cli bucket-create -c localhost --bucket-type=couchbase \
    --bucket=auth --bucket-ramsize=$AUTH_BUCKET_RAMSIZE -u Administrator -p password

echo "Creating data bucket"
couchbase-cli bucket-create -c localhost --bucket-type=couchbase \
    --bucket=data --bucket-ramsize=$DATA_BUCKET_RAMSIZE -u Administrator -p password

echo "Creating system bucket"
couchbase-cli bucket-create -c localhost --bucket-type=couchbase \
    --bucket=system --bucket-ramsize=$SYSTEM_BUCKET_RAMSIZE -u Administrator -p password

echo "Creating global bucket"
couchbase-cli bucket-create -c localhost --bucket-type=couchbase \
    --bucket=global --bucket-ramsize=$GLOBAL_BUCKET_RAMSIZE -u Administrator -p password

# Whitelist CURL URLs
echo "Whitelisting CURL URLs"
curl -s -X POST -u Administrator:password \
    -d "{\"all_access\": false, \"allowed_urls\" : [\"http://localhost:8094/\", \"http://$NODE_FQDN:8094\"] }" \
    http://localhost:8091/settings/querySettings/curlWhitelist

# Create documents, indexes, and design documents (views)
echo "Populating auth bucket"
cbdocloader -c couchbase://localhost -u Administrator -p password -m 100 \
    -b auth -d ./couchbase/auth-bucket/

echo "Populating data bucket"
cbdocloader -c couchbase://localhost -u Administrator -p password -m 100 \
    -b data -d ./couchbase/data-bucket/

echo "Populating system bucket"
cbdocloader -c couchbase://localhost -u Administrator -p password -m 100 \
    -b system -d ./couchbase/system-bucket/

echo "Populating global bucket"
cbdocloader -c couchbase://localhost -u Administrator -p password -m 100 \
    -b global -d ./couchbase/global-bucket/

# Create FTS indices
echo "Creating FTS indices"
for ftsIndex in .couchbase/fts-indices/*; do
    echo $ftsIndex
    curl -s -X PUT -u Administrator:password -H 'Content-Type: application/json' \
        -d @$ftsIndex \
        http://localhost:8094/api/index/$(basename $ftsIndex .json)
done

echo "Cluster configured!"
echo "NOTE, XDCR for the global bucket must be setup manually."
