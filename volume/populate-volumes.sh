
# az extension add -n containerapp

set -e


source ../config.env

set -x

ORG_NAME=${}

STORAGE_ACCOUNT_KEY=`az storage account keys list -n $STORAGE_ACCOUNT --query "[0].value" -o tsv`

CERTS_DIR_SHARE=organizationsdir
CERTS_DIR_MOUNT=organizationsmount

# PEER_CERTS_DIR_SHARE=peercertsdir
# PEER_CERTS_DIR_MOUNT=peercertsmount

# NETWORK_DIR_SHARE=networkdatadir
# NETWORK_DIR_MOUNT=networkdatamount


SDK_DIR_SHARE=sdkconnectionfile
SDK_DIR_MOUNT=sdkconnectionfilemount


SDK_WALLET_SHARE=sdkwallet
SDK_WALLET_MOUNT=sdkwalletmount


set +x

create_directory(){
  # Create a directory in the Azure File Share
  echo "Creating directory '$REMOTE_DIR_NAME' in file share '$STORAGE_SHARE_NAME'..."
  az storage directory create \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_ACCOUNT_KEY" \
    --share-name "$STORAGE_SHARE_NAME" \
    --name "$REMOTE_DIR_NAME" \
    --output table
}


populate_volume(){

  STORAGE_ACCOUNT=$1
  STORAGE_ACCOUNT_KEY=$2
  STORAGE_SHARE_NAME=$3
  STORAGE_MOUNT_NAME=$4
  LOCAL_DIR_PATH=$5

 
    set -x
    
      az storage file upload-batch \
        --account-name $STORAGE_ACCOUNT \
        --account-key $STORAGE_ACCOUNT_KEY \
        --source $LOCAL_DIR_PATH \
        --destination $STORAGE_SHARE_NAME \
        --destination-path $DESTINATION_DIR

    set +x
}



# --auth-mode
echo
echo "+++++++++++++++++++++++++++++++++"
echo "POPULATING ORGANIZATIONS DIR"
echo "+++++++++++++++++++++++++++++++++"
echo

# populate_volume $STORAGE_ACCOUNT $STORAGE_ACCOUNT_KEY $CERTS_DIR_SHARE $CERTS_DIR_MOUNT "../organizations"


echo
echo "+++++++++++++++++++++++++++++++++"
echo "ORGANIZATIONS DIR POPULATED"
echo "+++++++++++++++++++++++++++++++++"
echo

sleep 3

echo
echo "+++++++++++++++++++++++++++++++++"
echo "POPULATING PEERS CERTS DIR"
echo "+++++++++++++++++++++++++++++++++"
echo

PEERS_DIR=$(find ./organizations/peerOrganizations/*/peers -type d -maxdepth 0)

populate_volume $STORAGE_ACCOUNT $STORAGE_ACCOUNT_KEY $PEER0_CERTS_DIR_SHARE $PEER0_CERTS_DIR_MOUNT $PEERS_DIR



echo
echo "+++++++++++++++++++++++++++++++++"
echo "POPULATING PEERS CERTS USERS DIR"
echo "+++++++++++++++++++++++++++++++++"
echo


USERS_DIR=$(find ./organizations/peerOrganizations/*/users -type d -maxdepth 0)

create_directory $STORAGE_ACCOUNT $STORAGE_ACCOUNT_KEY $PEER0_CERTS_DIR_SHARE "users"

populate_volume $STORAGE_ACCOUNT $STORAGE_ACCOUNT_KEY $PEER0_CERTS_DIR_SHARE $PEER0_CERTS_DIR_MOUNT $USERS_DIR "users"


create_directory $STORAGE_ACCOUNT $STORAGE_ACCOUNT_KEY $PEER0_CERTS_DIR_SHARE "organizations"

populate_volume $STORAGE_ACCOUNT $STORAGE_ACCOUNT_KEY $PEER0_CERTS_DIR_SHARE $PEER0_CERTS_DIR_MOUNT ./organizations "users"


echo
echo "+++++++++++++++++++++++++++++++++"
echo "PEER CERTS DIR POPULATED"
echo "+++++++++++++++++++++++++++++++++"
echo



sleep 3

echo
echo "+++++++++++++++++++++++++++++++++"
echo "POPULATING NETWORK DIR"
echo "+++++++++++++++++++++++++++++++++"
echo


sudo chmod -R 777 ../../../network-data/peer0.HoganLovells.integra.com

populate_volume $STORAGE_ACCOUNT $STORAGE_ACCOUNT_KEY $NETWORK_DIR_SHARE $NETWORK_DIR_MOUNT "../../../network-data/peer0.integra.integra.com"



echo
echo "+++++++++++++++++++++++++++++++++"
echo "NETWORK DIR POPULATED"
echo "+++++++++++++++++++++++++++++++++"
echo



sleep 3

echo
echo "+++++++++++++++++++++++++++++++++"
echo "POPULATING NETWORK DIR"
echo "+++++++++++++++++++++++++++++++++"
echo


# mkdir ../organizations/peerOrganizations/integra.integra.com/connection-json || true
# cp ../organizations/peerOrganizations/integra.integra.com/connection-integra.json ../organizations/peerOrganizations/integra.integra.com/connection-json/connection.json  || true

# populate_volume $STORAGE_ACCOUNT $STORAGE_ACCOUNT_KEY $SDK_DIR_SHARE $SDK_DIR_MOUNT "../organizations/peerOrganizations/integra.integra.com/connection-json"



echo
echo "+++++++++++++++++++++++++++++++++"
echo "NETWORK DIR POPULATED"
echo "+++++++++++++++++++++++++++++++++"
echo
