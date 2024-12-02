


source ../config.env


echo
echo "=================================================="
echo "ENTERING INSTANCE CONTAINER :-"
echo "=================================================="
echo



RUNNING_REVISION=$(az containerapp revision list \
  --name $INSTANCE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "[?properties.runningState=='RunningAtMaxScale'].name" \
  --output tsv)


echo "RUNNING REVISION $RUNNING_REVISION"

echo
echo
set -x
az containerapp exec --name $INSTANCE_NAME --resource-group $RESOURCE_GROUP --revision $RUNNING_REVISION --command /bin/bash
if [ $? -ne 0 ]; then
    echo "First command failed. Running fallback command..."
    # Run the fallback command
   az containerapp exec --name $INSTANCE_NAME --resource-group $RESOURCE_GROUP --command /bin/bash

    # Check if the fallback command was successful
    if [ $? -ne 0 ]; then
        echo "Fallback command also failed. Exiting with error."
        exit 1
    fi
else
    echo "First command succeeded."
fi

set +x

