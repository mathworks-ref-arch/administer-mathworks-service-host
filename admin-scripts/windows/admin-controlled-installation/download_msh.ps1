# Copyright 2024 The MathWorks, Inc.

param (
    [string]$Release,
    [string]$Destination,
    [switch]$Help
)

# Exit if any command fails
$ErrorActionPreference = "Stop"

# Extract the script name and directory
$scriptPath = $PSCommandPath
$scriptName = Split-Path -Path $scriptPath -Leaf
$scriptDirectory = Split-Path -Path $scriptPath

# Utility function to print usage details and exit
function PrintUsageDetailsAndExit($e) {
    $message = Get-Content -Path "$scriptDirectory\man\download_msh.txt" -Raw
    if($e){
        Write-Error "`n$e `n$message"
    }else{
        Write-Host "$message"
    }
    exit 1
}

if($Help){
    PrintUsageDetailsAndExit
}

# Parse release
$releaseNumber = Get-Content -Path "$scriptDirectory\latest_release.txt" -Raw
$releaseSpecified = $false
if ($Release) {
    $releaseSpecified = $true
    $releaseNumber = $Release
    # Remove the starting v if it exists
    if ($releaseNumber -like "v*") {
        $releaseNumber = $releaseNumber.Substring(1)
    }
}
# Parse download directory and make sure it exists
if (-not $Destination) {
    PrintUsageDetailsAndExit "Missing download directory."
}
if (-not (Test-Path -Path $Destination)) {
    New-Item -ItemType Directory -Path "$Destination" | Out-Null
}
$downloadDirectory = (Resolve-Path -Path $Destination).Path

# Download the specified release
$downloadUrl = "https://ssd.mathworks.com/supportfiles/downloads/MathWorksServiceHost/v$releaseNumber/release/win64/managed_mathworksservicehost_${releaseNumber}_package_win64.zip"
$downloadZipFile = Join-Path -Path $downloadDirectory -ChildPath "managed_mathworksservicehost_${releaseNumber}_package_win64.zip" | Convert-Path
# $downloadZipFile = Convert-Path $downloadZipFile

Start-BitsTransfer -Source $downloadUrl -Destination $downloadZipFile

# Print the next steps needed for the installation
$M = ""
$M += "The MathWorks Service Host zip file has been downloaded in:`n"
$M += "`t $downloadDirectory`n"
$M += "`t In order to install it you can run:`n"
$M += "`t .\install_msh.ps1"
if ($releaseSpecified) {
    $M += " -Release $releaseNumber"
}
$M += " -Source `"$downloadDirectory`" -Destination <installation_directory>`n"

# Print the final message
Write-Host $M

exit 0
