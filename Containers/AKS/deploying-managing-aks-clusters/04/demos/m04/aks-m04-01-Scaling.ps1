# Cluster Auto Scaling
kubectl config use-context AKS-AZCLI-LARGE

kubectl get nodes -o wide

az aks update --resource-group $RG --name AKS-AZCLI-LARGE `
	--enable-cluster-autoscaler --min-count 2 --max-count 5

kubectl get nodes -o wide

Clear-Host










# Horizontal Pod Autoscaler
code nginx.yaml
kubectl apply -f nginx.yaml

kubectl get deployment nginx-deployment
kubectl get pods -o wide

kubectl autoscale deployment nginx-deployment --cpu-percent=50 --min=2 --max=5

kubectl get pods -o wide

$SERVICEIP=(kubectl get service nginx -o jsonpath='{ .status.loadBalancer.ingress[0].ip }')
Start-Process http://$SERVICEIP

kubectl get pods -o wide

kubectl run -i --rm httperfpod --image=cyrilbkr/httperf --restart=Never -- /bin/sh -c ("httperf --server " + $SERVICEIP  + " --wsess=10,1000,0 --rate 1")

kubectl get hpa

kubectl get pods -o wide

Clear-Host