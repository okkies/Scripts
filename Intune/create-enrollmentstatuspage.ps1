function CreateAndAssignEnrollmentConfiguration {
    param (
        [Parameter(Mandatory=$true)]
        [string]$accesstoken,

        [Parameter(Mandatory=$false)]
        [string]$prefix,
        
        [Parameter(Mandatory=$true)]
        [string]$autopilotgrp_id,
        
        [string]$custom_error_message = "Enter your custom error here"
    )

    # Fixed Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/deviceEnrollmentConfigurations"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"

    # JSON body for creating the enrollment configuration
    $json = @"
{
    "@odata.type": "#microsoft.graph.windows10EnrollmentCompletionPageConfiguration",
    "displayName": "$prefix AutoPilot Enrollment",
    "description": "Custom Enrollment Status",
    "showInstallationProgress": true,
    "blockDeviceSetupRetryByUser": false,
    "allowDeviceResetOnInstallFailure": false,
    "allowLogCollectionOnInstallFailure": true,
    "customErrorMessage": "$custom_error_message",
    "installProgressTimeoutInMinutes": 120,
    "allowDeviceUseOnInstallFailure": true
}
"@
    Write-Verbose "POST $uri`n$json"

    try {
        $headers = @{
            "Authorization" = "Bearer $accesstoken"
            "Content-Type" = "application/json"
        }
        $enrollment = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $json
    }
    catch {
        Write-Error $_.Exception 
        return
    }

    # Assign it
    $id = $enrollment.id

    # Construct URI for the assignment
    $assign_uri = "https://graph.microsoft.com/$graphApiVersion/$Resource/$id/assign"

    # JSON body for the assignment
    $assign_json = @"
{
    "enrollmentConfigurationAssignments": [
        {
            "target": {
                "@odata.type": "#microsoft.graph.groupAssignmentTarget",
                "groupId": "$autopilotgrp_id"
            }
        }
    ]
}
"@
    Write-Verbose "POST $assign_uri`n$assign_json"

    try {
        $headers = @{
            "Authorization" = "Bearer $accesstoken"
            "Content-Type" = "application/json"
        }
        Invoke-RestMethod -Uri $assign_uri -Method Post -Headers $headers -Body $assign_json
    }
    catch {
        Write-Error $_.Exception 
    }
}

# Example usage:
# CreateAndAssignEnrollmentConfiguration -accesstoken "your_access_token_here" -autopilotgrp_id "your_autopilot_group_id_here"
