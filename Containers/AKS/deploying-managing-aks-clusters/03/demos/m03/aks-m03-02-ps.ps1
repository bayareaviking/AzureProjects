# PowerShell and az module
# Check out the full reference at: https://docs.microsoft.com/de-de/powershell/module/az.aks
Install-Module Az
Update-Module Az

Connect-AzAccount -Subscription $Sub

Get-AzAksVersion -Location $Region | Select-Object OrchestratorVersion

New-AzAksCluster -ResourceGroupName $RG `
                    -Name AKS-PS `
                    -NodeCount 4 `
                    -NodeVmSize Standard_d16_v4 `
                    -KubernetesVersion 1.17.13

Get-AzAksCluster -ResourceGroupName $RG | Select-Object Name

Clear-Host