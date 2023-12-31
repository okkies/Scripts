<#
==================================================================================================================
Name:           Install Windows Store in Windows Sandbox
Description:    This script Installs Install Windows Store in Windows Sandbox
Version:        1.0
Date :          26/2/2023
Website:        https://bonben365.com
Script by:      https://github.com/bonben365
For detailed script execution: https://bonben365.com/how-to-install-windows-store-in-windows-sandbox-in-windows-11/
=================================================================================================================
#>

if (([Security.Principal.WindowsIdentity]::GetCurrent().Groups | Select-String 'S-1-5-32-544').count -eq 0) {    
    Write-Host "Error: Run the script as administrator"
    Write-Host "Exitting..."
    Start-Sleep -Seconds 3
    exit
}

if ([System.Environment]::OSVersion.Version.Build -lt 16299) {
    Write-Host "This pack is for Windows 10 version 1709 and later"
    Write-Host "Exitting..."
    Start-Sleep -Seconds 3
    exit
}

# Create temporary directory
$null = New-Item -Path $env:temp\temp -ItemType Directory -Force
Set-Location $env:temp\temp

# Download required files
Write-Host
Write-Host ============================================================
Write-Host Downloading dependency packages...
Write-Host ============================================================
Write-Host
$uri = "https://filedn.com/lOX1R8Sv7vhpEG9Q77kMbn0/bonben365.com/Zip/microsoftstore-win-ltsc.zip"
(New-Object Net.WebClient).DownloadFile($uri, "$env:temp\temp\microsoftstore-win-ltsc.zip")

# Extract downloaded file then run the script
Expand-Archive .\microsoftstore-win-ltsc.zip -Force -ErrorAction:SilentlyContinue | out-null
Set-Location "$env:temp\temp\microsoftstore-win-ltsc"

if ([System.Environment]::Is64BitOperatingSystem -like "True") {
    $arch = "x64"
} else {
    $arch = "x86"
}

if (!(Get-ChildItem "*WindowsStore*")) {    
    Write-Host "Error: Required files are missing in the current directory"
    Write-Host "Exitting..."
    Start-Sleep -Seconds 3
    exit
}

if ($arch -eq "x86") {
    $depens = Get-ChildItem | Where-Object {($_.Name -match '^*Microsoft.NET.Native*|^*VCLibs*') -and ($_.Name -like '*x86*')}
} 
if ($arch -eq "x64") {
    $depens = Get-ChildItem | Where-Object {$_.Name -match '^*Microsoft.NET.Native*|^*VCLibs*'}
}

Write-Host
Write-Host ============================================================
Write-Host Installing dependency packages
Write-Host ============================================================
Write-Host

foreach ($depen in $depens) {
    Add-AppxPackage -Path "$depen" -ErrorAction:SilentlyContinue
}

Write-Host
Write-Host ============================================================
Write-Host Adding Microsoft Store
Write-Host ============================================================
Write-Host
Add-AppxProvisionedPackage -Online -PackagePath "$(Get-ChildItem | Where-Object { ($_.Name -like '*WindowsStore*') -and ($_.Name -like '*AppxBundle*') })" -LicensePath "$(Get-ChildItem | Where-Object { ($_.Name -like '*WindowsStore*') -and ($_.Name -like '*xml*') })"

if ((Get-ChildItem "*StorePurchaseApp*")) {    
Write-Host
Write-Host ============================================================
Write-Host Adding Store Purchase App
Write-Host ============================================================
Write-Host   
Add-AppxProvisionedPackage -Online -PackagePath "$(Get-ChildItem | Where-Object { ($_.Name -like '*StorePurchaseApp*') -and ($_.Name -like '*AppxBundle*') })" -LicensePath "$(Get-ChildItem | Where-Object { ($_.Name -like '*StorePurchaseApp*') -and ($_.Name -like '*xml*') })"
}

if ((Get-ChildItem "*DesktopAppInstaller*")) {    
Write-Host
Write-Host ============================================================
Write-Host Adding App Installer
Write-Host ============================================================
Write-Host   
Add-AppxProvisionedPackage -Online -PackagePath "$(Get-ChildItem | Where-Object { ($_.Name -like '*DesktopAppInstaller*') -and ($_.Name -like '*AppxBundle*') })" -LicensePath "$(Get-ChildItem | Where-Object { ($_.Name -like '*DesktopAppInstaller*') -and ($_.Name -like '*xml*') })"
}

if ((Get-ChildItem "*XboxIdentityProvider*")) {    
Write-Host
Write-Host ============================================================
Write-Host XboxIdentityProvider
Write-Host ============================================================
Write-Host   
Add-AppxProvisionedPackage -Online -PackagePath "$(Get-ChildItem | Where-Object { ($_.Name -like '*XboxIdentityProvider*') -and ($_.Name -like '*AppxBundle*') })" -LicensePath "$(Get-ChildItem | Where-Object { ($_.Name -like '*XboxIdentityProvider*') -and ($_.Name -like '*xml*') })"
}

# Checking installed apps
$packages = @("Microsoft.VCLibs","DesktopAppInstaller","WindowsStore","Microsoft.NET.Native")
$report = ForEach ($package in $packages){Get-AppxPackage -Name *$package* | select Name,Version,Status }
write-host "Installed packages:"
$report | format-table

# Cleanup
Set-Location "$env:temp"
Remove-Item $env:temp\temp -Recurse -Force

Write-Host
Write-Host ============================================================
Write-Host Done
Write-Host ============================================================
Write-Host 