# Copyright 2024 The MathWorks, Inc.

param (
    [string]$Release,
    [string]$Source,
    [string]$Destination,
    [switch]$UpdateEnvironment,
    [switch]$NoUpdateEnvironment,
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
    $message = Get-Content -Path "$scriptDirectory\man\install_msh.txt" -Raw
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

# Define warning messages
$warningMessages = @{}
$warningMessages[0] = Get-Content -Path "$scriptDirectory\man\install_msh_warning_0.txt" -Raw
$warningMessages[1] = Get-Content -Path "$scriptDirectory\man\install_msh_warning_1.txt" -Raw

# Parse release
$releaseNumber = Get-Content -Path "$scriptDirectory\latest_release.txt" -Raw
if ($Release) {
    $releaseNumber = $Release
    # Remove the starting v if it exists
    if ($releaseNumber -like "v*") {
        $releaseNumber = $releaseNumber.Substring(1)
    }
}
# Parse download directory
if ($Source) {
    $downloadDirectorySpecified=$true
    $downloadDirectory = Convert-Path -Path $Source
}else{
    $downloadDirectorySpecified=$false
    $downloadDirectory = "$env:LOCALAPPDATA\MathWorks\ServiceHost\tmpZip"
    if (-not (Test-Path -Path $downloadDirectory)) {
        New-Item -ItemType Directory -Path "$downloadDirectory" | Out-Null
    }
    $downloadUrl = "https://ssd.mathworks.com/supportfiles/downloads/MathWorksServiceHost/v$releaseNumber/release/win64/managed_mathworksservicehost_${releaseNumber}_package_win64.zip"
    $downloadZipFile = Join-Path -Path $downloadDirectory -ChildPath "managed_mathworksservicehost_${releaseNumber}_package_win64.zip"
    Start-BitsTransfer -Source $downloadUrl -Destination $downloadZipFile
}

# Parse installation directory and make sure it exists
if (-not $Destination) {
    PrintUsageDetailsAndExit "Missing installation directory."
}
if (-not (Test-Path -Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination | Out-Null
}
$installationDirectory = Convert-Path $Destination

# Extract the zip into the desired location, replacing any existing installation of the same version
$downloadedZipFile = Join-Path -Path $downloadDirectory -ChildPath "managed_mathworksservicehost_${releaseNumber}_package_win64.zip"
if (-not (Test-Path -Path $downloadedZipFile)){
    Write-Error "The specified source directory does not contain the expected zip file:`n`t $downloadedZipFile"
    exit 1
}
$versionedInstallationDir = Join-Path -Path $installationDirectory -ChildPath "v$releaseNumber"
New-Item -Path $versionedInstallationDir -ItemType Directory -Force | Out-Null
Expand-Archive -Path $downloadedZipFile -DestinationPath $versionedInstallationDir -Force

# Cleanup the default download directory if used
if(-not $downloadDirectorySpecified){
    Remove-Item -Path $downloadDirectory -Recurse -Force 
}

# Create/Update the LatestInstall.info file in the installation directory
$doubleSlashVersionedInstallationDirectory = ""
for ($i = 0; $i -lt $versionedInstallationDir.Length; $i++) {
    $char = $versionedInstallationDir[$i]
    if ($char -eq '\') {
        $doubleSlashVersionedInstallationDirectory += '\\'
    } else {
        $doubleSlashVersionedInstallationDirectory += $char
    }
}

$latestInstallInfoFilePath = Join-Path -Path $installationDirectory -ChildPath "LatestInstall.info"
$lines = @(
    "LatestDSInstallerVersion $releaseNumber"
    "LatestDSInstallRoot `"$doubleSlashVersionedInstallationDirectory`""
    "DSLauncherExecutable `"$doubleSlashVersionedInstallationDirectory\\bin\\win64\\MathWorksServiceHost.exe`""
)
Set-Content -Path $latestInstallInfoFilePath -Value $lines

# Stop any processes which may be running from default installations
$allProcessNames = @("MATLABConnector", "MathWorksServiceHost")
foreach ($processName in $allProcessNames) {
    $proceses = Get-WmiObject Win32_Process | Where-Object { $_.Name -like "*$processName*" }
    foreach ($process in $proceses) {
    try {
            $process.Terminate() | Out-Null
    } catch {
        if (-not (($_.CategoryInfo.Category -eq "ObjectNotFound") -or ($_.CategoryInfo.Category -eq "NotSpecified"))) {
            Write-Error "Could not stop the process: $processName"
            throw;
            }
        }
    }
}

# Remove any previously installed versions of MathWorks Service Host
$directoriesToRemove = Get-ChildItem -Path $installationDirectory -Directory | Where-Object { $_.Name -like "v202*" -and $_.Name -ne "v$releaseNumber" }
foreach ($dir in $directoriesToRemove) {
    try {
        Remove-Item -Path $dir.FullName -Recurse -Force
    } catch {
        Write-Host "Failed to remove $($dir.FullName): $_" -ForegroundColor Red
    }
}

# Utility for updating the environment variable in the registry
function updateRegistry {
    $evName = "MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -Name $evName -Value $installationDirectory
    [System.Environment]::SetEnvironmentVariable($evName, $installationDirectory, [System.EnvironmentVariableTarget]::Machine)
    Set-Item -Path "Env:$evName" -Value $installationDirectory
 } 

# Update the registry to include MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT if the user agrees
if($UpdateEnvironment -and (-not $NoUpdateEnvironment) ){
    updateRegistry
}elseif((-not $UpdateEnvironment) -and ($NoUpdateEnvironment) ){
    Write-Host "Skipping update of the registry to set MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT system wide"
} else {
    $response = Read-Host "Would you like to update the registry to set MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT system wide? (Y/n)"
    if ([string]::IsNullOrWhiteSpace($response)) {
        $response = "Y"
    }
    switch -Regex ($response) {
    "^[yY](es)?$" {
        updateRegistry
    }
    "^[nN](o)?$" {
        Write-Host "Skipping update of registry."
    }
    default {
        Write-Host "Unknown option, will not update the registry."
    }
    }
}

# Print warnings if MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT is not set
$ev = $env:MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT
if (-not $ev) {
    Write-Output  "`n$($warningMessages[0])"
} else { 
    if (-not (Test-Path -Path  $ev)) {
        New-Item -ItemType Directory -Path  $ev | Out-Null
    }
    $evInstallationDirectory = (Resolve-Path -Path  $ev).Path
    if ($installationDirectory -ne $evInstallationDirectory){
        Write-Output  "`n$($warningMessages[1])"
    }
}

Write-Output "MathWorks Service Host has been installed in $installationDirectory"

exit 0