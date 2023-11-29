function CreateAutopilotProfile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$accesstoken,

        [Parameter(Mandatory=$true)]
        [string]$LanguageTag,

        [Parameter(Mandatory=$true)]
        [string]$prefix,

        [string]$profilename = "Autopilot Profile"
    )

    # Fixed Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/windowsAutopilotDeploymentProfiles"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"

    # JSON body for creating the Autopilot profile
    $json = @"
{
    "@odata.type": "#microsoft.graph.azureADWindowsAutopilotDeploymentProfile",
    "displayName": "$profilename",
    "description": "OOBE Autopilot Profile",
    "language": "$LanguageTag",
    "extractHardwareHash": true,
    "deviceNameTemplate": "$prefix-%SERIAL%",
    "deviceType": "windowsPc",
    "enableWhiteGlove": true,
    "outOfBoxExperienceSettings": {
        "hidePrivacySettings": true,
        "hideEULA": true,
        "userType": "standard",
        "deviceUsageType": "singleUser",
        "skipKeyboardSelectionPage": false,
        "hideEscapeLink": true
    },
    "enrollmentStatusScreenSettings": {
        "@odata.type": "microsoft.graph.windowsEnrollmentStatusScreenSettings",
        "hideInstallationProgress": false,
        "allowDeviceUseBeforeProfileAndAppInstallComplete": true,
        "blockDeviceSetupRetryByUser": true,
        "allowLogCollectionOnInstallFailure": true,
        "installProgressTimeoutInMinutes": 120,
        "allowDeviceUseOnInstallFailure": true
    }
}
"@
    Write-Verbose "POST $uri`n$json"

    try {
        $headers = @{
            "Authorization" = "Bearer $accesstoken"
            "Content-Type" = "application/json"
        }
        Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $json
    }
    catch {
        Write-Error $_.Exception 
    }
}

# Example usage:
# CreateAutopilotProfile -accesstoken "your_access_token_here" -LanguageTag "nl-NL" -prefix "DEV"
