
# az extension add -n containerapp

set -e

set -x

sudo apt-get remove -y azure-cli


sudo rm /etc/apt/sources.list.d/azure-cli. || true

rm -rf  ~/.azure || true

echo
echo "================================================================================"
echo "INSTALLING AZURE CLI"
echo "================================================================================"
echo

sudo apt-get update 

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

az upgrade

az extension add --name containerapp --upgrade --allow-preview true


az login --use-device-code

az provider register --namespace Microsoft.App

az provider register --namespace Microsoft.OperationalInsights

set +x