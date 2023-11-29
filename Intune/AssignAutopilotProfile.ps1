function AssignAutopilotProfile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$accesstoken,
        
        [Parameter(Mandatory=$true)]
        [string]$profilename,
        
        [Parameter(Mandatory=$true)]
        [string]$autopilotgrp_id
    )
    
    # Get AutoPilot Profile
    $ap1 = Get-AutoPilotProfile -name $profilename
    $id = $ap1.id
    
    # Fixed Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/windowsAutopilotDeploymentProfiles"        
    $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource/$id/assignments"
    
    $full_assignment_id = $id + "_" + $autopilotgrp_id + "_0"
    
    $json = @"
{
    "id": "$full_assignment_id",
    "target": {
        "@odata.type": "#microsoft.graph.groupAssignmentTarget",
        "groupId": "$autopilotgrp_id"
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
# AssignAutopilotProfile -accesstoken "your_access_token_here" -profilename "Autopilot Profile" -autopilotgrp_id "your_autopilot_group_id_here"
