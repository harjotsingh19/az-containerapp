
source ../config.env


RUNNING_REVISION=$(az containerapp revision list \
  --name $INSTANCE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "[?properties.runningState=='RunningAtMaxScale' || properties.runningState=='Running'].name" \
  --output tsv)



echo "RUNNING REVISION $RUNNING_REVISION"

echo
echo
set -x
az containerapp logs show --resource-group $RESOURCE_GROUP --name $INSTANCE_NAME --revision $RUNNING_REVISION --follow --tail 200
if [ $? -ne 0 ]; then
    echo "First command failed. Running fallback command..."
    # Run the fallback command
   az containerapp logs show --resource-group $RESOURCE_GROUP --name $INSTANCE_NAME --follow --tail 200

    # Check if the fallback command was successful
    if [ $? -ne 0 ]; then
        echo "Fallback command also failed. Exiting with error."
        exit 1
    fi
else
    echo "First command succeeded."
fi

set +x


# az containerapp logs show --resource-group $RESOURCE_GROUP --name $INSTANCE_NAME --follow 
