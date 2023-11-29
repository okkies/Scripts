Function Get-AutoPilotProfileAssignments(){
    
    <#
    .SYNOPSIS
    This function is used to get AutoPilot Profile assignment from the Graph API REST interface
    .DESCRIPTION
    The function connects to the Graph API Interface and gets an Autopilot profile assignment
    .EXAMPLE
    Get-AutoPilotProfileAssignments $id guid
    Returns any autopilot profile assignment configured in Intune
    .NOTES
    NAME: Get-AutoPilotProfileAssignments
    #>
    
    [cmdletbinding()]
    
    param
    (
        [Parameter(Mandatory=$true,HelpMessage="Enter id (guid) for the Autopilot Profile you want to check assignment")]
        $id,

        [Parameter(Mandatory=$true)]
        [string]$accesstoken
    )
    
    $graphApiVersion = "Beta"
    $DCP_resource = "deviceManagement/windowsAutopilotDeploymentProfiles"
    $headers = @{
        "Authorization" = "Bearer $accesstoken"
    }
    
    try {
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($DCP_resource)/$id/Assignments"
        (Invoke-RestMethod -Uri $uri -Method Get -Headers $headers).Value
    }
    
    catch {
        $ex = $_.Exception
        if ($ex -is [System.Net.WebException]) {
            $errorResponse = $ex.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd()
        } elseif ($_ -is [Microsoft.PowerShell.Commands.HttpResponseException]) {
            $responseBody = $_.ErrorDetails.Message
        } else {
            $responseBody = "An unexpected error occurred: $ex"
        }
        Write-Host "Response content:`n$responseBody" -f Red
        Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        write-host
    }
    
}

# Example usage:
# Get-AutoPilotProfileAssignments -id "your_id_here" -accesstoken "your_access_token_here"
