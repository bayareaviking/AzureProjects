# ARM Templates
az bicep install

code aks-arm.json

$SSH=(Get-Content ~\.ssh\id_rsa.pub)

az Deployment group create -f aks-arm.json -g $RG `
                --parameters sshRSAPublicKey=$SSH clusterName=AKS-ARM-JSON agentCount=1

az bicep decompile --file aks-arm.json
code aks-arm.bicep

az Deployment group create -f aks-arm.bicep `
                -g $RG `
                --parameters sshRSAPublicKey=$SSH clusterName=AKS-ARM-BICEP agentCount=1


az aks list -o table

Clear-Host