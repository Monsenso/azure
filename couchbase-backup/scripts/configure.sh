#!/usr/bin/env bash

echo "Running server.sh"

version=$1
username=$2
password=$3
couchbaseUrl=$4
backupCronExpression=$5

echo "Installing Couchbase Server..."
wget https://packages.couchbase.com/releases/${version}/couchbase-server-enterprise_${version}-ubuntu16.04_amd64.deb
dpkg -i couchbase-server-enterprise_${version}-ubuntu16.04_amd64.deb
if [[ $? -eq 1 ]]
then
    echo "Failed to install Couchbase"
    exit 1
fi
apt-get update
apt-get -y install couchbase-server jq

systemctl stop couchbase-server
systemctl disable couchbase-server

echo "Calling util.sh..."
source util.sh
formatDataDisk
turnOffTransparentHugepages
setSwappinessToZero
adjustTCPKeepalive

cp couchbase-backup.sh backup-util.sh /opt/couchbase/bin
chown couchbase:couchbase \
    /opt/couchbase/bin/couchbase-backup.sh /opt/couchbase/bin/backup-util.sh
echo "$backupCronExpression root /opt/couchbase/bin/couchbase-backup.sh \"$couchbaseUrl\" \"$username\" \"$password\"" >> /etc/crontab
