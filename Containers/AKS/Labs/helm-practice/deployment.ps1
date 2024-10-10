$tenantID = "027ae224-51cb-4c9a-b8c8-be9b6d46383b"
$subID = "d70a6468-b750-4907-a466-f89146780348"
$CLUSTER_NAME = "aks-store-demo"
$RESOURCE_GROUP = "rg-aks-store-demo"
$REGISTRY = "aksstoredemo563983"
$LOCATION = "eastus"

az login --tenant $tenantID

# 
az group create --name $RESOURCE_GROUP --location $LOCATION
az acr create --resource-group $RESOURCE_GROUP --name $REGISTRY --sku Basic
az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-count 2 --attach-acr $REGISTRY --generate-ssh-keys

az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
kubectl get nodes