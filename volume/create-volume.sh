
# az extension add -n containerapp

# set -e


source ../config.env


STORAGE_ACCOUNT_KEY=`az storage account keys list -n $STORAGE_ACCOUNT --query "[0].value" -o tsv`


CERTS_DIR_SHARE=organizationsdir
CERTS_DIR_MOUNT=organizationsmount

# PEER0_CERTS_DIR_SHARE=peer0certs
# PEER0_CERTS_DIR_MOUNT=peer0certsmount


# NETWORK_DIR_SHARE=networkdata
# NETWORK_DIR_MOUNT=networkdatamount


SDK_DIR_SHARE=sdkconnectionfile
SDK_DIR_MOUNT=sdkconnectionfilemount


SDK_WALLET_SHARE=sdkwallet
SDK_WALLET_MOUNT=sdkwalletmoun




deleteStorageAccount() {

  StorageAccountName=$1
  StorageShareName=$2
  StorageMountName=$3
  RESOURCE_GROUP=$4

  # Remove the storage mount from the Azure Container App environment
  az containerapp env storage remove \
    --resource-group $RESOURCE_GROUP \
    --name $ENVIRONMENT \
    --storage-name $StorageMountName \
    --output table

  # Delete the Azure file share
  az storage share-rm delete \
    --resource-group $RESOURCE_GROUP \
    --storage-account $StorageAccountName \
    --name $StorageShareName \
    --output table

  # Delete the Azure storage account
  az storage account delete \
    --resource-group $RESOURCE_GROUP \
    --name $StorageAccountName \
    --yes \
    --output table
}

# Example usage
# deleteStorageAccount hlfdata organizationsdir organizationsmount $RESOURCE_GROUP




createStorageResources() {


  set -x
  RESOURCE_GROUP=$1
  StorageAccountName=$2
  StorageShareName=$3
  StorageMountName=$4
  ENVIRONMENT=$5
  LOCATION=${6:-eastus}


  echo
  echo "Checking if resource group '$RESOURCE_GROUP' exists..."
  if ! az group show --name $RESOURCE_GROUP &>/dev/null; then
    echo
    echo "Resource group '$RESOURCE_GROUP' does not exist. Creating it..."
    az group create --name $RESOURCE_GROUP --location $LOCATION --output table
  else
    echo
    echo "Resource group '$RESOURCE_GROUP' exists."
  fi


  echo
  echo
  echo "Checking if storage account '$StorageAccountName' exists..."
  if ! az storage account show --name $StorageAccountName --resource-group $RESOURCE_GROUP &>/dev/null; then
    echo
    echo "Storage account '$StorageAccountName' does not exist. Creating it..."
    az storage account create \
      --name $StorageAccountName \
      --resource-group $RESOURCE_GROUP \
      --location $LOCATION \
      --kind StorageV2 \
      --sku Standard_LRS \
      --output table
  else
    echo
    echo "Storage account '$StorageAccountName' exists."
  fi


  sleep 40
  echo
  echo "Checking if file share '$StorageShareName' exists in storage account '$StorageAccountName'..."
  if ! az storage share-rm show --name $StorageShareName --storage-account $StorageAccountName --resource-group $RESOURCE_GROUP &>/dev/null; then
    echo
    echo "File share '$StorageShareName' does not exist. Creating it..."
    az storage share-rm create \
      --resource-group $RESOURCE_GROUP \
      --storage-account $StorageAccountName \
      --name $StorageShareName \
      --quota 1 \
      --enabled-protocols SMB \
      --output table
  else
    echo
    echo "File share '$StorageShareName' already exists."
  fi


  sleep 20

  echo
  echo "Retrieving storage account key..."
      StorageAccountName_KEY=`az storage account keys list -n $StorageAccountName --query "[0].value" -o tsv`
  echo "🚀 ~ createStorageResources ~ StorageAccountName_KEY:", $StorageAccountName_KEY

  # echo "Checking if storage is already set in Container App Environment '$ENVIRONMENT'..."
  # if ! az containerapp env storage list \
  #   --name $ENVIRONMENT \
  #   --resource-group $RESOURCE_GROUP \
  #   --query "[?name=='$StorageMountName']" \
  #   --output tsv &>/dev/null; then
  #   echo "Storage mount '$StorageMountName' is not set. Configuring it..."
    az containerapp env storage set \
      --access-mode ReadWrite \
      --azure-file-account-name $StorageAccountName \
      --azure-file-account-key $StorageAccountName_KEY \
      --azure-file-share-name $StorageShareName \
      --storage-name $StorageMountName \
      --name $ENVIRONMENT \
      --resource-group $RESOURCE_GROUP \
      --output table
  
    echo
    echo "Storage mount '$StorageMountName' is already configured in Container App Environment '$ENVIRONMENT'."
  

  echo "All resources and configurations completed successfully."
}

createStorageResources $RESOURCE_GROUP $STORAGE_ACCOUNT $PEER0_CERTS_DIR_SHARE $PEER0_CERTS_DIR_MOUNT $ENVIRONMENT $LOCATION


createStorageResources $RESOURCE_GROUP $STORAGE_ACCOUNT $NETWORK_DIR_SHARE $NETWORK_DIR_MOUNT $ENVIRONMENT $LOCATION


# createStorageResources $RESOURCE_GROUP $STORAGE_ACCOUNT "networkdatadir" "networkdatamount" $$ENVIRONMENT $LOCATION



# createStorageResources $RESOURCE_GROUP $STORAGE_ACCOUNT "sdkconnectionfile" "sdkconnectionfilemount" $$ENVIRONMENT $LOCATION

# createStorageResources $RESOURCE_GROUP $STORAGE_ACCOUNT "sdkwallet" "sdkwalletmount" $$ENVIRONMENT $LOCATION