

$tenantID = "f2081a36-aea7-456d-95f6-8d3ea75cddad"
$appID = "199635c5-620a-42af-aa63-99ea378006a8"
$thumb = "C8E8AD68C3E5D1926640DD5524214F6DBC6F33D9"
#Import-Module AzureAD
Connect-AzureAD -TenantId $tenantID -ApplicationId $appID -CertificateThumbprint $thumb 
$passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$passwordProfile.Password = "Pass@word123!"
$cn = "admin"
[string]$domain = $(Get-AzureADTenantDetail).VerifiedDomains.Name
$displayName = "Tenant Admin"
[string]$upn = $cn + "@" + $domain


$roleUser = New-AzureADUser -UserPrincipalName $upn -DisplayName $displayName -PasswordProfile $passwordProfile -AccountEnabled $true -MailNickName $cn -Verbose -ErrorAction Stop
$roleDef = Get-AzureADMSRoleDefinition -Filter "DisplayName eq 'Global Administrator'"
#$scope = "/" + $tenantID

New-AzureADMSRoleAssignment -DirectoryScopeId '/' -RoleDefinitionId $roleDef.Id -PrincipalId $roleUser.ObjectId -Verbose