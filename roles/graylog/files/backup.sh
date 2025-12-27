#!/bin/bash

set -e

echo "Running sync script"

TIMESTAMP_RFC3339=$(date --rfc-3339=seconds)
MONGODB_FILENAME=$SERVICE_NAME-mongodb-latest.tar.gz
MONGODB_TAR_FILE=/tmp/$MONGODB_FILENAME
DATANODE_FILENAME=$SERVICE_NAME-datanode-latest.tar.gz
DATANODE_TAR_FILE=/tmp/$DATANODE_FILENAME
CERT_DIR=/backup-toolkit

rm -rf $MONGODB_TAR_FILE $DATANODE_TAR_FILE || true

echo "Backing up $SERVICE_NAME"

# Backing up MongoDB
echo "Performing mongodump"
mongodump --uri="mongodb://mongodb:27017"

cd /dump

trap 'echo "Backup command failed. Cleaning up..."; rm -f "$MONGODB_TAR_FILE" "$DATANODE_TAR_FILE" zi*; exit 1' ERR

echo "Creating MongoDB tarball $MONGODB_TAR_FILE"
tar -czvf $MONGODB_TAR_FILE --warning=none .
echo "Created $MONGODB_TAR_FILE"

# Backing up Datanode (OpenSearch)
echo "Creating snapshot repository for datanode if it doesn't exist"

# Check if the snapshot repository exists, create it if it doesn't
REPO_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" https://datanode:9200/_snapshot/backup-repo --key $CERT_DIR/private.key --cert $CERT_DIR/private.crt --cacert $CERT_DIR/ca.crt )
if [ "$REPO_EXISTS" != "200" ]; then
  echo "Creating snapshot repository backup-repo"
  curl -X PUT "https://datanode:9200/_snapshot/backup-repo" --key $CERT_DIR/private.key --cert $CERT_DIR/private.crt --cacert $CERT_DIR/ca.crt -H 'Content-Type: application/json' -d '
  {
    "type": "fs",
    "settings": {
      "location": "/var/lib/graylog-datanode/snapshots"
    }
  }'
fi

# Create a snapshot with current timestamp
SNAPSHOT_NAME="snapshot-$(date +%Y%m%d%H%M%S)"
echo "Taking snapshot $SNAPSHOT_NAME of OpenSearch indices"
curl -X PUT "https://datanode:9200/_snapshot/backup-repo/$SNAPSHOT_NAME?wait_for_completion=true" --key $CERT_DIR/private.key --cert $CERT_DIR/private.crt --cacert $CERT_DIR/ca.crt

echo "Creating OpenSearch tarball $DATANODE_TAR_FILE"
cd /data/opensearch
tar -czvf $DATANODE_TAR_FILE --warning=none ./snapshots
echo "Created $DATANODE_TAR_FILE"

trap - ERR

# Upload MongoDB backup
echo "Uploading MongoDB backup to s3://$BUCKET_NAME/$SERVICE_NAME/$MONGODB_FILENAME"
aws s3 cp $MONGODB_TAR_FILE s3://$BUCKET_NAME/$SERVICE_NAME/$MONGODB_FILENAME
echo "Backed up MongoDB to s3://$BUCKET_NAME/$SERVICE_NAME/$MONGODB_FILENAME"

# Upload Datanode backup
echo "Uploading Datanode backup to s3://$BUCKET_NAME/$SERVICE_NAME/$DATANODE_FILENAME"
aws s3 cp $DATANODE_TAR_FILE s3://$BUCKET_NAME/$SERVICE_NAME/$DATANODE_FILENAME
echo "Backed up Datanode to s3://$BUCKET_NAME/$SERVICE_NAME/$DATANODE_FILENAME"

echo "Setting time to topic \"backup/$SERVICE_NAME/time\""
mosquitto_pub -h $MOSQUITTO_HOST -t "backup/$SERVICE_NAME/time" -m "$TIMESTAMP_RFC3339" -u "$MOSQUITTO_USERNAME" -P "$MOSQUITTO_PASSWORD" --retain

echo "Finished backing up $SERVICE_NAME"
