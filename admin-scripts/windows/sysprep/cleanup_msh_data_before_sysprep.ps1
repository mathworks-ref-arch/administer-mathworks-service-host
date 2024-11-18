# Copyright 2024 The MathWorks, Inc.

# Exit if any command fails
$ErrorActionPreference = "Stop"

# Stop any processes which may be using MathWorks Service Host
$allProcessNames = @("MATLAB", "MATLABConnector", "MathWorksServiceHost")
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

$LocalAppData = "$env:LOCALAPPDATA"
$AppData = "$env:APPDATA"

# Clean up all user specific directories
$directories= @("$LocalAppData\MathWorks\ServiceHost",
                "$LocalAppData\MathWorks\MATLABConnector",
                "$LocalAppData\MathWorks\mwEndpointRegistry",
                "$AppData\MathWorks\licensing",
                "$AppData\MathWorks\credentials")
foreach ($directory in $directories) {
    try {
        Remove-Item -Path $directory -Recurse -Force -ErrorAction Stop
    } catch {
        if (-not ($_.CategoryInfo.Category -eq "ObjectNotFound")) {
            throw;
        }
    }
}
