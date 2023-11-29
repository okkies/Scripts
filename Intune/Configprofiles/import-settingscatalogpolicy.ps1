Function Add-SettingsCatalogPolicy {
    param (
        [parameter(Mandatory=$true)]
        [string]$JSON,
        [string]$accessToken
    )

    $graphApiVersion = "beta"
    $resource = "deviceManagement/configurationPolicies"

    try {
        if ([string]::IsNullOrWhiteSpace($JSON)) {
            Write-Host "No JSON specified, please specify valid JSON for the Endpoint Security Disk Encryption Policy..." -ForegroundColor Red
            return
        }

        $uri = "https://graph.microsoft.com/$graphApiVersion/$resource"
        $headers = @{
            'Content-Type' = 'application/json'
            'Authorization' = "Bearer $accessToken"
        }
        Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $JSON
        Write-Host "Settings Catalog Policy added successfully."
    }
    catch {
        $ex = $_.Exception
        Write-Host "Exception Message: $($ex.Message)" -ForegroundColor Red
        if ($ex.Response -and $ex.Response.Content) {
            try {
                $responseContent = $ex.Response.Content.ReadAsStringAsync().Result
                Write-Host "Response Content: $responseContent" -ForegroundColor Red
            } catch {
                Write-Host "Failed to read response content" -ForegroundColor Red
            }
        }
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    }
    
    
}


Function Test-JSON {
    param (
        $JSON
    )

    try {
        $null = ConvertFrom-Json $JSON -ErrorAction Stop
        $true
    }
    catch {
        Write-Host "Error in JSON format: $($_.Exception.Message)" -ForegroundColor Red
        $false
    }
}

Function Prepare-JsonForImport {
    param (
        [string]$JSON
    )

    try {
        $jsonObject = ConvertFrom-Json $JSON

        # Assuming 'settings' is an array of setting instances
        $settingsArray = @($jsonObject.Settings) 

        $policyForImport = @{
            name = $jsonObject.Policy.name
            description = $jsonObject.Policy.description
            platforms = $jsonObject.Policy.platforms
            technologies = $jsonObject.Policy.technologies
            settingCount = $jsonObject.Policy.settingCount
            roleScopeTagIds = $jsonObject.Policy.roleScopeTagIds
            templateReference = $jsonObject.Policy.templateReference
            priorityMetaData = $jsonObject.Policy.priorityMetaData
            settings = $settingsArray
        }

        $preparedJson = $policyForImport | ConvertTo-Json -Depth 10
        Write-Host "Prepared JSON for import: $preparedJson" -ForegroundColor Green
        return $preparedJson
    }
    catch {
        Write-Error "Error in Prepare-JsonForImport: $_"
        return $null
    }
}



# Main script starts here

$ImportPath = Read-Host -Prompt "Please specify a path to a JSON file to import data from e.g. C:\IntuneOutput\Policies\policy.json"

if (!(Test-Path "$ImportPath")) {
    Write-Host "Import Path for JSON file doesn't exist..." -ForegroundColor Red
    Write-Host "Script can't continue..." -ForegroundColor Red
    return
}

$JSON_Data = Get-Content "$ImportPath" -Raw

if (Test-JSON -JSON $JSON_Data) {
    $Prepared_JSON = Prepare-JsonForImport -JSON $JSON_Data
    if ($null -ne $Prepared_JSON) {
        Write-Host "Adding Settings Catalog Policy from file: $ImportPath" -ForegroundColor Yellow
        Add-SettingsCatalogPolicy -JSON $Prepared_JSON -accessToken $accessToken
    }
    else {
        Write-Host "Failed to prepare JSON for import" -ForegroundColor Red
    }
}


