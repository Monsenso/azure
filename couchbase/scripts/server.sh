#!/usr/bin/env bash

echo "Running server.sh"

version=$1
adminUsername=$2
adminPassword=$3
serverName=$4
uniqueString=$5
location=$6

echo "Using the settings:"
echo adminUsername \'$adminUsername\'
echo adminPassword \'$adminPassword\'
echo uniqueString \'$uniqueString\'
echo location \'$location\'

echo "Installing Couchbase Server..."
wget https://packages.couchbase.com/releases/${version}/couchbase-server-enterprise_${version}-ubuntu16.04_amd64.deb
dpkg -i couchbase-server-enterprise_${version}-ubuntu16.04_amd64.deb
if [[ $? -eq 1 ]]
then
    echo "Failed to install Couchbase"
    exit 1
fi
apt-get update
apt-get -y install couchbase-server

echo "Calling util.sh..."
source util.sh
formatDataDisk
turnOffTransparentHugepages
setSwappinessToZero
adjustTCPKeepalive

echo "Configuring Couchbase Server..."
apt-get -y install jq
nodeIndex=`curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute?api-version=2017-04-02" \
  | jq ".name" \
  | sed 's/.*_//' \
  | sed 's/"//'`

printf -v nodeDNS "$serverName%06d.au.private.monsenso.com\n" $nodeIndex
rallyDNS=$serverName'000000.au.private.monsenso.com'

echo "Adding an entry to /etc/hosts to simulate split brain DNS..."
echo "
# Simulate split brain DNS for Couchbase
127.0.0.1 ${nodeDNS}
" >> /etc/hosts

#######################################################
####### Wait until web interface is available #########
####### Needed for the cli to work	          #########
#######################################################

checksCount=0

printf "Waiting for server startup..."
until curl -o /dev/null -s -f http://localhost:8091/ui/index.html || [[ $checksCount -ge 50 ]]; do
   (( checksCount += 1 ))
   printf "." && sleep 3
done
echo "server is up."

if [[ "$checksCount" -ge 50 ]]
then
  printf >&2 "ERROR: Couchbase Webserver is not available after script Couchbase REST readiness retry limit" 
fi

cd /opt/couchbase/bin/

echo "Running couchbase-cli node-init"
./couchbase-cli node-init \
  --cluster=$nodeDNS \
  --node-init-hostname=$nodeDNS \
  --node-init-data-path=/datadisk/data \
  --node-init-index-path=/datadisk/index \
  --username=$adminUsername \
  --password=$adminPassword

if [[ $nodeIndex == "0" ]]
then
  totalRAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  dataRAM=$((50 * $totalRAM / 100000))
  indexRAM=$((10 * $totalRAM / 100000))
  ftsRAM=$((5 * $totalRAM / 100000))
  eventingRAM=$((5 * $totalRAM / 100000))

  echo "Running couchbase-cli cluster-init"
  ./couchbase-cli cluster-init \
    --cluster=$nodeDNS \
    --cluster-ramsize=$dataRAM \
    --cluster-index-ramsize=$indexRAM \
    --cluster-fts-ramsize=$ftsRAM \
    --cluster-eventing-ramsize=$eventingRAM \
    --cluster-username=$adminUsername \
    --cluster-password=$adminPassword \
    --services=data,index,query,fts,eventing
else
  echo "Running couchbase-cli server-add"
  output=""
  while [[ $output != "Server $nodeDNS:8091 added" && ! $output =~ "Node is already part of cluster." ]]
  do
    output=`./couchbase-cli server-add \
      --cluster=$rallyDNS \
      --username=$adminUsername \
      --password=$adminPassword \
      --server-add=$nodeDNS \
      --server-add-username=$adminUsername \
      --server-add-password=$adminPassword \
      --services=data,index,query,fts,eventing`

    echo server-add output \'$output\'
    sleep 10
  done

  echo "Running couchbase-cli rebalance"
  output=""
  while [[ ! $output =~ "SUCCESS" ]]
  do
    output=`./couchbase-cli rebalance \
      --cluster=$rallyDNS \
      --username=$adminUsername \
      --password=$adminPassword`
    echo rebalance output \'$output\'
    sleep 10
  done

fi
