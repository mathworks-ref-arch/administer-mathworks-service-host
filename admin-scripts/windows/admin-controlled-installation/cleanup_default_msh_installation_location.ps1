# Copyright 2024 The MathWorks, Inc.

param (
    [switch]$ForAllUsers,
    [string]$Excluding,
    [switch]$Force,
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
    $message = Get-Content -Path "$scriptDirectory\man\cleanup_default_msh_installation_location.txt" -Raw
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

$basePath = "$env:LOCALAPPDATA\MathWorks\ServiceHost\"
$draftDirectories =  Get-ChildItem -Path $basePath -Depth 1 -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
$draftDirectories =  $draftDirectories | Where-Object { $_ -match 'MathWorks\\ServiceHost\\v202[0-9\.]+$' }

if ($ForAllUsers){
    $allUsersBasePath = "$env:LOCALAPPDATA\MathWorks\ServiceHost\"
    $allUsersBasePath = $allUsersBasePath -replace $env:USERNAME, "*"
    $draftDirectories =  Get-ChildItem -Path $allUsersBasePath -Depth 1 -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    $draftDirectories =  $draftDirectories | Where-Object { $_ -match 'MathWorks\\ServiceHost\\v202[0-9\.]+$' }
}

$excludingRegex="(?!a)a" # Never matching regex
if($Excluding){
    $excludingRegex = $Excluding
}
$directoriesToCleanup = $draftDirectories | Where-Object { $_ -notmatch $excludingRegex }

if ($directoriesToCleanup.Count -eq 0) {
    Write-Output "No MathWorks Service Host installations found to cleanup."
    exit 0
}

# Utility for cleaning up all found directories
function DoCleanup() {
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

    # Wait for the processes to go away before proceeding to cleanup
    foreach ($processName in $processNames) {
        $maxAttempts = 5
        for ($attempt = 0; $attempt -lt $maxAttempts; $attempt++) {
            if (-not (Get-Process -Name $processName -ErrorAction SilentlyContinue)) {
                break
            }
            Start-Sleep -Seconds 1
        }
    }

    # Cleanup
    foreach ($dir in $directoriesToCleanup ){
        Remove-Item -Path $dir -Recurse -Force
    }
}

if ($Force){
    Write-Output "Cleaning up the following MathWorks Service Host installations:"
    foreach ($dir in $directoriesToCleanup ){
        Write-Output "`t$dir"
    }
    DoCleanup
    Write-Output "Cleanup completed."
}else{
    Write-Output "Found the following MathWorks Service Host installations:"
    foreach ($dir in $directoriesToCleanup ){
        Write-Output "`t$dir"
    }
    Write-Output "Deleting all the above requires that:"
    Write-Output "`t - you have installed MathWorks Service Host into a custom location, and"
    Write-Output "`t - you have set the environment variable MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT"
    Write-Output "`t   to that custom installation path"
    $response = Read-Host "Do you want to proceed? (y/N):"
    switch -Regex ($response) {
    "^[yY](es)?$" {
        DoCleanup
    }
    "^[nN](o)?$" {
        Write-Host "Cancelling cleanup."
    }
    default {
        Write-Host "Unknown option, cancelling cleanup."
    }
    }
    Write-Output "Cleanup completed."
}
exit 0
