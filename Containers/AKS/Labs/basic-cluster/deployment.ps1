$tenantID = "027ae224-51cb-4c9a-b8c8-be9b6d46383b"
$subID = "d70a6468-b750-4907-a466-f89146780348"
$CLUSTER_NAME = "aks-contoso-video"
$RESOURCE_GROUP = "rg-contoso-video"

az login --tenant $tenantID

az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP