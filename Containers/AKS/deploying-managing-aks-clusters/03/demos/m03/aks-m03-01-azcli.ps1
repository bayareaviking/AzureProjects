# Azure CLI
# Check the full reference at: https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest
az login
az account set -s $Sub

az group create -l $Region -n $RG

az aks create -g $RG -n AKS-AZCLI-DEFAULT

az aks create -g $RG -n AKS-AZCLI-SMALL --node-count 2

az aks create --generate-ssh-keys -g $RG -n AKS-AZCLI-LARGE `
              --node-count 4 --node-vm-size Standard_d16_v4

az aks list -o table

az aks browse -n AKS-AZCLI-LARGE -g $RG 

Clear-Host