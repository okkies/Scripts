# Start Transcript logging
Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\LAPSLocalAdmin_Remediate.log" -Append

$LAPSAdmin = "LapsDog"

# Check if the user exists
$UserExists = Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount=True" | Where-Object { $_.Name -eq $LAPSAdmin }

If (-not $UserExists) {

    Write-Output "User: $LAPSAdmin does not exist on the device, creating user"
    
    try {
        # Define the length of the password
        $length = 14

        # Define the characters to be used in the password
        $characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+=-"

        # Create a random password
        $password = -join (1..$length | ForEach-Object { Get-Random -InputObject $characters })

        # Create the user
        New-LocalUser -Name $LAPSAdmin -Password (ConvertTo-SecureString -AsPlainText $password -Force) -Description "LAPS Admin User"
        Write-Output "Added Local User $LAPSAdmin"

        # Add user to Administrators group
        Add-LocalGroupMember -Group "Administrators" -Member $LAPSAdmin
        Write-Output "Added Local User $LAPSAdmin to Administrators"
    }
    catch {
        Write-Error "Couldn't create user: $_"
    }
}
Else {
    Write-Output "User $LAPSAdmin exists on the device"
}

# Stop Transcript logging
Stop-Transcript
