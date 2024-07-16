

# Create the self signed cert
$currentDate = Get-Date
$endDate = $currentDate.AddYears(1)
$notAfter = $endDate.AddYears(1)
$password = Read-Host -Prompt "Enter a password" #-AsSecureString
$certName = Read-Host -Prompt "Enter cert name" 
$dnsName = "$certName.tenant.test"
$securePass = ConvertTo-SecureString -String $password -Force -AsPlainText

# Test
New-SelfSignedCertificate -CertStoreLocation cert:\CurrentUser\my -DnsName $dnsName -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $notAfter -Verbose

#$thumb = (New-SelfSignedCertificate -CertStoreLocation cert:\localmachine\my -DnsName $dnsName -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $notAfter).Thumbprint
#Export-PfxCertificate -cert "cert:\localmachine\my\$thumb" -FilePath c:\temp\$certName.pfx -Password $securePass -Verbose -Force

<#
# Load the certificate
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate("C:\temp\$certName.pfx", $securePass)
$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())
#>
