
# az extension add -n containerapp

set -e

source ../config.env


echo
echo "=================================================="
echo "DELETING CONTAINER APP :-"
echo "=================================================="
echo


az containerapp delete --name $INSTANCE_NAME --resource-group $RESOURCE_GROUP --yes || true
echo
echo "=================================================="
echo "INSTANCE CONTAINER CREATION :-"
echo "=================================================="
echo

set -x

docker build -t $ACR_NAME.azurecr.io/ubuntu:20.04 .

az acr login --name $ACR_NAME

Registry_username=$(az acr credential show -n $ACR_NAME --query username -o tsv)
Registry_pass=$(az acr credential show -n $ACR_NAME --query 'passwords[0].value' -o tsv)


docker push $ACR_NAME.azurecr.io/ubuntu:20.04 

DOCKER_IMAGE=$ACR_NAME.azurecr.io/ubuntu:20.04


az containerapp create \
  --name $INSTANCE_NAME \
  --resource-group $RESOURCE_GROUP \
  --image $DOCKER_IMAGE \
  --cpu 2 \
  --memory 4Gi \
  --environment $ENVIRONMENT \
  --min-replicas 1 \
  --max-replicas 1 \
  --target-port 3000 \
  --ingress 'external' \
  --transport auto \
  --query properties.configuration.ingress.fqdn \
  --registry-username $Registry_username \
  --registry-password $Registry_pass \
  --registry-server $ACR_NAME.azurecr.io \
  # --command "npm start"
  # --command "echo '20.253.18.211 peer0.HoganLovells.integra.com' >> /etc/hosts && npm start"


# az containerapp create \
#   --name $INSTANCE_NAME \
#   --resource-group $RESOURCE_GROUP \
#   --image ubuntu:20.04 \
#   --cpu 2 \
#   --memory 4Gi \
#   --environment $ENVIRONMENT \
#   --min-replicas 1 \
#   --max-replicas 1 \
#   --target-port 3000 \
#   --ingress 'external' \
#   --transport auto \
#   --query properties.configuration.ingress.fqdn \
#   --registry-username $Registry_username \
#   --registry-password $Registry_pass \
#   --registry-server $ACR_NAME.azurecr.io \
#   --command "tail -f /dev/null"

curl "http://34.162.80.4:7005/download?filePath=$HOME/hlf-rg.zip" --output hlf-org.zip


# Fetch the DNS name and IP address of the container app
OUTPUT=$(az containerapp show --resource-group "$RESOURCE_GROUP" --name "$INSTANCE_NAME" --query "{dnsName:properties.configuration.ingress.fqdn, ipAddresses:properties.outboundIpAddresses}" -o tsv)

# Extract DNS Name and IP Address
SDK_DNS=$(echo "$OUTPUT" | awk '{print $1}')
# IP_ADDRESSES=$(echo "$OUTPUT" | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')


set +x