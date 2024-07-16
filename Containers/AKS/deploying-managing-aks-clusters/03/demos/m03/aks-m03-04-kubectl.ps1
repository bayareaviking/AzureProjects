# Communicating with our cluster
az aks get-credentials -g $RG -n AKS-PS

kubectl cluster-info
kubectl get nodes -o wide

az aks get-credentials -g $RG -n AKS-ARM-BICEP

kubectl get nodes -o wide

foreach ($cluster in (Get-AzAksCluster -ResourceGroupName $RG )) {
    az aks get-credentials -g $RG -n $cluster.Name
}

kubectl config view
kubectl config view -o jsonpath='{range .contexts[*]}{.name}{''\n''}{end}'

kubectl config current-context

Clear-Host