Function Get-DeviceConfigurationPolicyAssignment(){
    
    <#
    .SYNOPSIS
    This function is used to get device configuration policy assignment from the Graph API REST interface
    .DESCRIPTION
    The function connects to the Graph API Interface and gets a device configuration policy assignment
    .EXAMPLE
    Get-DeviceConfigurationPolicyAssignment $id guid
    Returns any device configuration policy assignment configured in Intune
    .NOTES
    NAME: Get-DeviceConfigurationPolicyAssignment
    #>
    
    [cmdletbinding()]
    
    param
    (
        [Parameter(Mandatory=$true,HelpMessage="Enter id (guid) for the Device Configuration Policy you want to check assignment")]
        $id,
        
        [Parameter(Mandatory=$true)]
        [string]$accesstoken
    )
    
    $graphApiVersion = "Beta"
    $DCP_resource = "deviceManagement/deviceConfigurations"
    $headers = @{
        "Authorization" = "Bearer $accesstoken"
    }
    
    try {
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($DCP_resource)/$id/groupAssignments"
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