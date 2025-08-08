# Copyright 2024 The MathWorks, Inc.

# Exit if any command fails
$ErrorActionPreference = "Stop"


# Stop any processes which may be using MathWorks Service Host
$allProcessNames = @("MATLAB", "MATLABConnector", "MathWorksServiceHost")
$remainingProcesses = @()
foreach ($processName in $allProcessNames) {
    $proceses = Get-WmiObject Win32_Process | Where-Object { $_.Name -like "*$processName*" }
    foreach ($process in $proceses) {
        try {
            $process.Terminate() | Out-Null
        } catch {
            if (-not (($_.CategoryInfo.Category -eq "ObjectNotFound") -or ($_.CategoryInfo.Category -eq "NotSpecified"))) {
                $remainingProcesses += "$processName"
            }
        }
    }
}

if ($remainingProcesses.Count -gt 0) {
    $remainingProcessesList = $remainingProcesses -join "`n`t"
    throw "Could not stop the processes:`n`t$remainingProcessesList"
}

$defaultProfile = Join-Path $env:SystemDrive 'Users\Default'
$defaultLocalAppData = Join-Path $defaultProfile 'AppData\Local'
$defaultAppData = Join-Path $defaultProfile 'AppData\Roaming'


$profileDirectories = @{
    LocalAppData = @(
        "$env:LOCALAPPDATA",
        $defaultLocalAppData
    )
    AppData = @(
        "$env:APPDATA",
        $defaultAppData
    )
}

$subdirectories = @{
    LocalAppData = @(
        'MathWorks\ServiceHost',
        'MathWorks\MATLABConnector',
        'MathWorks\mwEndpointRegistry'
    )
    AppData = @(
        'MathWorks\licensing',
        'MathWorks\credentials'
    )
}

$directories = @()
foreach ($base in $profileDirectories.LocalAppData) {
    foreach ($sub in $subdirectories.LocalAppData) {
        $directories += Join-Path $base $sub
    }
}
foreach ($base in $profileDirectories.AppData) {
    foreach ($sub in $subdirectories.AppData) {
        $directories += Join-Path $base $sub
    }
}

$remainingDirectories = @()
foreach ($directory in $directories) {
    try {
        Remove-Item -Path $directory -Recurse -Force -ErrorAction Stop
    } catch {
        if (-not ($_.CategoryInfo.Category -eq "ObjectNotFound")) {
            $remainingDirectories += "$directory"
        }
    }
}

if ($remainingDirectories.Count -gt 0) {
    $remainingDirectoriesList = $remainingDirectories -join "`n`t"
    throw "Could not remove the directories:`n`t$remainingDirectoriesList"
}

$M = ""
$M += "MathWorks Service Host is cleaned up, and you can now run ``sysprep``. `n"
$M += "Please note that any use of MathWorks product before ``sysprep`` will revert the cleanup, requiring that this script is run again. `n"

Write-Host $M

exit 0