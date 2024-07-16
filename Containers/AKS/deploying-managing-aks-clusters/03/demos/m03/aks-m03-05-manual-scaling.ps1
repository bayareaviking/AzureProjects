# Manual scaling
kubectl get nodes

az aks show --resource-group $RG --name AKS-PS --query agentPoolProfiles[0].name

$nodepool=(az aks show --resource-group $RG --name AKS-PS --query agentPoolProfiles[0].name)

az aks scale --resource-group $RG --name AKS-PS --node-count 5 --nodepool-name $nodepool

kubectl get nodes

Clear-Host