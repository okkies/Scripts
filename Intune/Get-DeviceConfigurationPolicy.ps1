Function Get-DeviceConfigurationPolicy(){
    
    <#
    .SYNOPSIS
    This function is used to get device configuration policies from the Graph API REST interface
    .DESCRIPTION
    The function connects to the Graph API Interface and gets any device configuration policies
    .EXAMPLE
    Get-DeviceConfigurationPolicy
    Returns any device configuration policies configured in Intune
    .NOTES
    NAME: Get-DeviceConfigurationPolicy
    #>
    
    [cmdletbinding()]
    
    param
    (
        [Parameter(Mandatory=$false)]
        [string]$name,

        [Parameter(Mandatory=$true)]
        [string]$accesstoken
    )
    
    $graphApiVersion = "beta"
    $DCP_resource = "deviceManagement/deviceConfigurations"
    $headers = @{
        "Authorization" = "Bearer $accesstoken"
    }

    try {
    
        if($Name){
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($DCP_resource)?`$filter=displayName eq '$name'"
            (Invoke-RestMethod -Uri $uri -Method Get -Headers $headers).value
        }
    
        else {
            $uri = "https://graph.microsoft.com/$graphApiVersion/$($DCP_resource)"
            (Invoke-RestMethod -Uri $uri -Method Get -Headers $headers).Value
        }
    
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
# Get-DeviceConfigurationPolicy -accesstoken "your_access_token_here"
