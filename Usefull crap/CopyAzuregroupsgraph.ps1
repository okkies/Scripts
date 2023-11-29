# Base URI for Microsoft Graph API
$graphApiUri = "https://graph.microsoft.com/v1.0"

# Authorization and content headers
$header = @{
    Authorization = "Bearer $accessToken"
    "Content-Type"  = "application/json"
}

# Mapping of source group IDs to destination group IDs
$groupMapping = @{
    "..-..-..-.." = "..-..-..-.." #braams


    # ... [Add more mappings as needed]
}

# Loop through each group mapping
foreach ($entry in $groupMapping.GetEnumerator()) {
    $sourceGroupId = $entry.Key
    $destinationGroupId = $entry.Value
    
    # Fetch details of the source group
    $group = Invoke-RestMethod -Uri "$graphApiUri/groups/$sourceGroupId" -Headers $header
    
    Write-Host "Copying members from group with ID: $($sourceGroupId) and Name: $($group.displayName) to group with ID: $($destinationGroupId)"
    
    # Fetch members of the source group
    $membersResponse = Invoke-RestMethod -Uri "$graphApiUri/groups/$sourceGroupId/members" -Headers $header

    # Extract member IDs from the response
    $memberIds = $membersResponse.value | ForEach-Object { $_.id }

    # Generate binding URIs for members
    $memberBindings = @($memberIds | ForEach-Object { "https://graph.microsoft.com/v1.0/directoryObjects/$_" })

    # Split memberBindings into chunks of 20 for batch processing
    $chunks = [System.Collections.ArrayList]@{}
    for ($i = 0; $i -lt $memberBindings.Count; $i += 20) {
        $chunks.Add($memberBindings[$i..($i+19)])
    }

    # Loop through each chunk and add members to the destination group
    foreach ($chunk in $chunks) {
        $addMembersBody = @{
            "members@odata.bind" = $chunk
        }
    
        $null = Invoke-RestMethod -Uri "$graphApiUri/groups/$destinationGroupId" -Headers $header -Method PATCH -Body ($addMembersBody | ConvertTo-Json -Depth 10)
        Write-Host "Added $($chunk.Count) members to the group with ID: $($destinationGroupId)"
    }
}

Write-Host "All members have been copied to the destination groups!"
