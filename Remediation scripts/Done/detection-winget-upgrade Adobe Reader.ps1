## Help System to find winget.exe
$JBNWinGetResolve = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
$JBNWinGetPathExe = $JBNWinGetResolve[-1].Path

$JBNWinGetPath = Split-Path -Path $JBNWinGetPathExe -Parent
set-location $JBNWinGetPath

## Variables
$JBNAppID = "Adobe.Acrobat.Reader.32-bit"
$JBNAppFriendlyName = "Adobe.Acrobat.Reader.32-bit"

## Check locally installed software version
$JBNLocalInstalledSoftware = .\winget.exe list -e --id $JBNAppID --accept-source-agreements

$JBNAvailable = (-split $JBNLocalInstalledSoftware[-3])[-2]

## Check if needs update
if ($JBNAvailable -eq 'Available')
{
    write-host $JBNAppFriendlyName "is installed but not the latest version, needs an update"
    exit 1
}

if ($JBNAvailable -eq 'Version')
{
    write-host $JBNAppFriendlyName "is installed and is the latest version"
    exit 1
}

if (!$JBNAvailable)
{
    write-host $JBNAppFriendlyName " is not installed"
    exit 0
}