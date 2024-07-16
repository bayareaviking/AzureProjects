# Stop/Start a Cluster
az aks show -n AKS-AZCLI-SMALL -g $RG --query powerState
az aks stop -n AKS-AZCLI-SMALL -g $RG
az aks show -n AKS-AZCLI-SMALL -g $RG --query powerState
az aks start -n AKS-AZCLI-SMALL -g $RG

# Delete a Cluster
az aks delete -n AKS-AZCLI-SMALL -g $RG

# Delete the RG
az group delete -n $RG

Clear-Host