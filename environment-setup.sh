# az extension add -n containerapp

set -e

source ./config.env

# Check if the resource group already exists
echo
echo "=================================================="
echo "CHECKING IF RESOURCE GROUP EXISTS"
echo "=================================================="
echo

if az group exists --name $RESOURCE_GROUP; then
    echo "Resource group '$RESOURCE_GROUP' already exists. Skipping creation."
else
    echo "Resource group '$RESOURCE_GROUP' does not exist. Creating..."
    az group create --name $RESOURCE_GROUP --location $LOCATION
fi

echo
echo "=================================================="
echo "CHECKING IF ENVIRONMENT EXISTS"
echo "=================================================="
echo

# Check if the container app environment already exists
if az containerapp env show --name $ENVIRONMENT --resource-group $RESOURCE_GROUP &> /dev/null; then
    echo "Environment '$ENVIRONMENT' already exists. Skipping creation."
else
    echo "Environment '$ENVIRONMENT' does not exist. Creating..."
    az containerapp env create --name $ENVIRONMENT --resource-group $RESOURCE_GROUP --location $LOCATION
fi

echo
echo "=================================================="
echo "CHECKING IF ACR EXISTS"
echo "=================================================="
echo

# Check if the Azure Container Registry (ACR) already exists
if az acr show --resource-group $RESOURCE_GROUP --name $ACR_NAME &> /dev/null; then
    echo "Azure Container Registry '$ACR_NAME' already exists. Skipping creation."
else
    echo "Azure Container Registry '$ACR_NAME' does not exist. Creating..."
    az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku standard --admin-enabled false
fi
