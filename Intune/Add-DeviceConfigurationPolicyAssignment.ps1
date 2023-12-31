Function Add-DeviceConfigurationPolicyAssignmentSC(){

    <#
    .SYNOPSIS
    This function is used to add a device configuration policy assignment using the Graph API REST interface  Settings Catalog
    .DESCRIPTION
    The function connects to the Graph API Interface and adds a device configuration policy assignment
    .EXAMPLE
    Add-DeviceConfigurationPolicyAssignment -ConfigurationPolicyId $ConfigurationPolicyId -TargetGroupId $TargetGroupId
    Adds a device configuration policy assignment in Intune
    .NOTES
    NAME: Add-DeviceConfigurationPolicyAssignment
    #>

    [cmdletbinding()]

    param
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ConfigurationPolicyId,

        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $TargetGroupId,

        [parameter(Mandatory=$true)]
        [ValidateSet("Included","Excluded")]
        [ValidateNotNullOrEmpty()]
        [string]$AssignmentType,
        
        [parameter(Mandatory=$true)]  # Added parameter for Access Token
        [string]$AccessToken
    )

    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/configurationPolicies/$ConfigurationPolicyId/assign"

    $headers = @{
        "Authorization" = "Bearer $AccessToken"  # Authorization header
        "Content-Type" = "application/json"
    }

    try {

        if(!$ConfigurationPolicyId){

            write-host "No Configuration Policy Id specified, specify a valid Configuration Policy Id" -f Red
            break

        }

        if(!$TargetGroupId){

            write-host "No Target Group Id specified, specify a valid Target Group Id" -f Red
            break

        }

        # Checking if there are Assignments already configured in the Policy
        $DCPA = Get-DeviceConfigurationPolicyAssignmentSC -id $ConfigurationPolicyId

        $TargetGroups = @()

        if(@($DCPA).count -ge 1){
            
            if($DCPA.targetGroupId -contains $TargetGroupId){

            Write-Host "Group with Id '$TargetGroupId' already assigned to Policy..." -ForegroundColor Red
            Write-Host
            break

            }

            # Looping through previously configured assignements

            $DCPA | foreach {

            $TargetGroup = New-Object -TypeName psobject
     
                if($_.excludeGroup -eq $true){

                    $TargetGroup | Add-Member -MemberType NoteProperty -Name '@odata.type' -Value '#microsoft.graph.exclusionGroupAssignmentTarget'
     
                }
     
                else {
     
                    $TargetGroup | Add-Member -MemberType NoteProperty -Name '@odata.type' -Value '#microsoft.graph.groupAssignmentTarget'
     
                }

            $TargetGroup | Add-Member -MemberType NoteProperty -Name 'groupId' -Value $_.targetGroupId

            $Target = New-Object -TypeName psobject
            $Target | Add-Member -MemberType NoteProperty -Name 'target' -Value $TargetGroup

            $TargetGroups += $Target

            }

            # Adding new group to psobject
            $TargetGroup = New-Object -TypeName psobject

                if($AssignmentType -eq "Excluded"){

                    $TargetGroup | Add-Member -MemberType NoteProperty -Name '@odata.type' -Value '#microsoft.graph.exclusionGroupAssignmentTarget'
     
                }
     
                elseif($AssignmentType -eq "Included") {
     
                    $TargetGroup | Add-Member -MemberType NoteProperty -Name '@odata.type' -Value '#microsoft.graph.groupAssignmentTarget'
     
                }
     
            $TargetGroup | Add-Member -MemberType NoteProperty -Name 'groupId' -Value "$TargetGroupId"

            $Target = New-Object -TypeName psobject
            $Target | Add-Member -MemberType NoteProperty -Name 'target' -Value $TargetGroup

            $TargetGroups += $Target

        }

        else {

            # No assignments configured creating new JSON object of group assigned
            
            $TargetGroup = New-Object -TypeName psobject

                if($AssignmentType -eq "Excluded"){

                    $TargetGroup | Add-Member -MemberType NoteProperty -Name '@odata.type' -Value '#microsoft.graph.exclusionGroupAssignmentTarget'
     
                }
     
                elseif($AssignmentType -eq "Included") {
     
                    $TargetGroup | Add-Member -MemberType NoteProperty -Name '@odata.type' -Value '#microsoft.graph.groupAssignmentTarget'
     
                }
     
            $TargetGroup | Add-Member -MemberType NoteProperty -Name 'groupId' -Value "$TargetGroupId"

            $Target = New-Object -TypeName psobject
            $Target | Add-Member -MemberType NoteProperty -Name 'target' -Value $TargetGroup

            $TargetGroups = $Target

        }

    # Creating JSON object to pass to Graph
    $Output = New-Object -TypeName psobject

    $Output | Add-Member -MemberType NoteProperty -Name 'assignments' -Value @($TargetGroups)

    $JSON = $Output | ConvertTo-Json -Depth 3

    # POST to Graph Service
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
    Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $JSON  # Updated Invoke method

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
    break

    }

}
