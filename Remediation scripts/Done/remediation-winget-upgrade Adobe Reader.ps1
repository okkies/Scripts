
######## Remediation script #########
### Software Remediation Script to update the software
### Author: John Bryntze
### Date: 6th January 2023

## Help System to find winget.exe
$JBNWinGetResolve = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
$JBNWinGetPathExe = $JBNWinGetResolve[-1].Path

$JBNWinGetPath = Split-Path -Path $JBNWinGetPathExe -Parent
set-location $JBNWinGetPath

## Variables
$JBNAppID = "Adobe.Acrobat.Reader.32-bit"

## Run upgrade of the software

try{
    .\winget.exe Uninstall -e --id $JBNAppID --silent --purge --disable-interactivity 
    exit 0

}catch{
    Write-Error "Error while installing upgarde for: $JBNAppID"
    exit 1
}
