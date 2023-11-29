function Get-SettingsCatalogPolicy {
    param (
        [string]$accessToken,
        [string]$graphApiVersion = "beta",
        [string]$platform = $null
    )

    $resource = "deviceManagement/configurationPolicies"
    if ($platform) {
        $resource += "?`$filter=platforms eq '$platform'"
    }

    $uri = "https://graph.microsoft.com/$graphApiVersion/$resource"

    try {
        $headers = @{
            Authorization = "Bearer $accessToken"
        }

        $policies = @()
        do {
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
            $policies += $response.value
            $uri = $response.'@odata.nextLink'
        } while ($uri -ne $null)

        return $policies
    } catch {
        Write-Error "Error in Get-SettingsCatalogPolicy: $_"
    }
}


function Get-SettingsCatalogPolicySettings {
    param (
        [string]$accessToken,
        [string]$policyId,
        [string]$graphApiVersion = "beta" # Use the beta version
    )

    # Correcting the resource path
    $resource = "deviceManagement/configurationPolicies/$policyId/settings"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$resource"

    try {
        $headers = @{
            Authorization = "Bearer $accessToken"
        }
        return (Invoke-RestMethod -Uri $uri -Headers $headers -Method Get).value
    } catch {
        Write-Error "Error in Get-SettingsCatalogPolicySettings: $_"
    }
}


function Export-JSONData {
    param (
        $data,
        [string]$exportPath
    )

    try {
        if (!$data) {
            throw "No data provided for export."
        }

        if (-not (Test-Path -Path $exportPath -PathType Container)) {
            throw "Export path '$exportPath' does not exist."
        }

        $json = $data | ConvertTo-Json -Depth 15
        $policyName = $data.Policy.name -replace '[\\\/:*?"<>|]', '' # Remove invalid characters
        $fileName = [IO.Path]::Combine($exportPath, "${policyName}.json")
        $json | Set-Content -Path $fileName
        Write-Host "Data exported to $fileName"
    } catch {
        Write-Error "Error in Export-JSONData: $_"
    }
}



# Example Usage:
$exportPath = "C:\IntuneOutput" # Define your export path here
$policies = Get-SettingsCatalogPolicy -accessToken $accessToken

foreach ($policy in $policies) {
    $settings = Get-SettingsCatalogPolicySettings -accessToken $accessToken -policyId $policy.id
    $exportData = @{
        Policy    = $policy
        Settings  = $settings
    }
    Export-JSONData -data $exportData -exportPath $exportPath
}
