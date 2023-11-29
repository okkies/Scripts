function Assign-UpdateRings {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PolicyName,
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Group,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Included","Excluded")]
        [string]$AssignmentType
    )
    $DCP = Get-DeviceConfigurationPolicy -name $PolicyName

    if($DCP) {
        $Assignment = Add-DeviceConfigurationPolicyAssignment -ConfigurationPolicyId $DCP.id -TargetGroupId $Group.id -AssignmentType $AssignmentType
        Write-Verbose "Assigned '$($Group.Name)' to $($DCP.displayName)/$($DCP.id)"
    } else {
        Write-Error "Can't find Device Configuration Policy with name '$PolicyName'..."
    }
}

$Rings = @{
    'Pilot Ring' = @{
        Group = $pilotgrp
        AssignmentType = 'Included'
    }
    'Preview Ring' = @{
        Group = $previewgrp
        AssignmentType = 'Included'
    }
    'VIP Channel' = @{
        Group = $vipgrp
        AssignmentType = 'Included'
    }
    'Broad Ring' = @{
        Group = $vipgrp
        AssignmentType = 'Excluded'
    }
}

foreach ($RingName in $Rings.Keys) {
    Assign-DeviceConfigurationPolicy -PolicyName $RingName -Group $Rings[$RingName].Group -AssignmentType $Rings[$RingName].AssignmentType
}

# For Broad Ring, additional groups are excluded
if ($Rings['Broad Ring']) {
    Assign-DeviceConfigurationPolicy -PolicyName 'Broad Ring' -Group $pilotgrp -AssignmentType 'Excluded'
    Assign-DeviceConfigurationPolicy -PolicyName 'Broad Ring' -Group $previewgrp -AssignmentType 'Excluded'
    Assign-DeviceConfigurationPolicy -PolicyName 'Broad Ring' -Group $autopilotgrp -AssignmentType 'Included'
}
