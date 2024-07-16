# Windows Nodes
az aks nodepool add  --resource-group $RG --cluster-name AKS-PS `
                     --os-type Windows --name npwind --node-count 1

kubectl get nodes -o wide

# https://docs.microsoft.com/en-us/azure/aks/windows-container-cli
code windows-app.yaml

kubectl apply -f windows-app.yaml

kubectl get pods -o wide

kubectl create deployment nginx --image=nginx
kubectl get pods -o wide

kubectl get service sample
$SERVICEIP=(kubectl get service sample -o jsonpath='{ .status.loadBalancer.ingress[0].ip }')

Start-Process http://$SERVICEIP

Clear-Host