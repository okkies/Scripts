$clientID = "<fillme>" #  App Id MS Graph API Connector SPN
$TenantName = "<tenant>.onmicrosoft.com" # Example bliepbloep.onmicrosoft.com
$TenantID = "<fillme2>" # Tenant ID 
$CertificatePath = "Cert:\LocalMachine\my\<certpath>" # Add the Certificate Path Including Thumbprint here e.g. cert:\currentuser\my\6C1EE1A11F57F2495B57A567211220E0ADD72DC1 >#
##Import Certificate

$Certificate = Get-Item $certificatePath

if (-not $Certificate) {
    Write-Host "Certificate is empty"
    exit
}

function Get-GraphAccessToken {
    param(
        [string]$clientID,              # Client ID (Application ID) of the Azure AD applicationg
        [string]$tenantID,              # Azure AD tenant ID
        [string]$certificateThumbprint  # Thumbprint of the certificate used for authentication
    )

    # Get the certificate from the certificate store using the provided thumbprint
    $certificate = Get-Item $CertificatePath

    <# Check if the NuGet package provider is installed, if not, install it
    if (-not (Get-PackageProvider -Name 'NuGet' -ListAvailable -ErrorAction SilentlyContinue)) {
        Write-Host "Installing NuGet package provider..."
        Install-PackageProvider -Name 'NuGet' -Force 
    }

    # Install the required Azure PowerShell modules if not already installed
    if (-not (Get-InstalledModule -Name 'Az.Accounts' -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Az.Accounts module..."
        Install-Module -Name 'Az.Accounts' -Scope CurrentUser -AllowPrerelease -Force
    }

    if (-not (Get-InstalledModule -Name 'microsoft.graph.authentication' -ErrorAction SilentlyContinue)) {
        Write-Host "Installing microsoft.graph.authentication module..."
        Install-Module -Name 'microsoft.graph.authentication' -Scope CurrentUser -AllowPrerelease -Force
    }

    if (-not (Get-InstalledModule -Name 'Exchangeonlinemanagement' -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Exchangeonlinemanagement..."
        Install-Module -Name 'Exchangeonlinemanagement' -Scope CurrentUser -Force -AllowPrerelease
    }
    Set-ExecutionPolicy Bypass -Scope LocalMachine

    # Import the Az.Accounts module
    Import-Module -Name 'Az.Accounts' -ErrorAction Stop 
#>
    # Connect to Azure using the Azure PowerShell module and the provided credentials
    Connect-AzAccount -Tenant $tenantID -ApplicationId $clientID -CertificateThumbprint $certificate.Thumbprint 

    # Get the access token using the connected Azure context
    $token = Get-AzAccessToken -ResourceUrl 'https://graph.microsoft.com' 
    $accessToken = $token.Token



    # Return the custom object
    return $token
    return $accessToken
    Disconnect-AzAccount
}

# Call the function and store the returned values
$token = Get-GraphAccessToken -clientID $clientID -tenantID $tenantID -certificateThumbprint $certificateThumbprint

#new way of connecting, with secure string
try {
    $secureAccessToken = $Token.Token | ConvertTo-SecureString -AsPlainText -Force
    Connect-MgGraph -AccessToken $secureAccessToken
	$accesstoken = $token.Token
    Write-host "connected to $TenantName"
} 
#old way of connecting, with plain text
catch {
    Connect-MgGraph -Token $token.Token
    $accesstoken = $token.Token
    Write-host "connected to $TenantName"
}


