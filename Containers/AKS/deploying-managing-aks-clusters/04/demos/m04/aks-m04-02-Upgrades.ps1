# Manually upgrade our cluster
az aks show -n AKS-AZCLI-LARGE -g $RG -o table

az aks get-versions -l $Region -o table

az aks get-upgrades -n AKS-AZCLI-LARGE -g $RG -o table

kubectl get nodes

az aks upgrade -n AKS-AZCLI-LARGE -g $RG --kubernetes-version 1.19.6

kubectl get nodes

az aks get-upgrades -n AKS-AZCLI-LARGE -g $RG -o table




# Auto Upgrade Channels
az aks update -n AKS-AZCLI-LARGE -g $RG --auto-upgrade-channel rapid

# This is in preview!
az feature register --namespace Microsoft.ContainerService -n AutoUpgradePreview
# Registration takes a few minutes - make sure the State shows "Registered"!
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/AutoUpgradePreview')].{Name:name,State:properties.state}"
az provider register --namespace Microsoft.ContainerService
az extension add --name aks-preview

# Now we can set the channel
az aks update -n AKS-AZCLI-LARGE -g $RG --auto-upgrade-channel rapid

# Remove the extension again - this will not affect our cluster itself
az extension remove --name aks-preview

Clear-Host