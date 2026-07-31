# Administer MathWorks Service Host

MathWorks&reg; Service Host is a collection of background processes that provide required services to MATLAB&reg; and other MathWorks products. Starting from MATLAB Release 2024a, MATLAB requires MathWorks Service Host. MathWorks Service Host processes run in the background even when other MathWorks products are closed, but they are designed to be lightweight and to not affect system performance.

By default, MathWorks Service Host is installed to the `%LOCALAPPDATA%\MathWorks` or `$HOME/MathWorks` directory of each user's machine, and it automatically updates to the latest version when a new one is available. A new version of MathWorks Service Host is released every four weeks. One installation of MathWorks Service Host supports all versions of MATLAB.

If you need more control over where MathWorks Service Host is installed, and when it is updated, you can use the scripts in the [admin-scripts](./admin-scripts) folder. These scripts allow you to install a configuration of MathWorks Service Host which supports alternative installation locations and does not attempt to automatically update itself. These scripts will be updated every four weeks to reflect each new release of MathWorks Service Host. When you install an update, you get the bug fixes and security patches included in the update and all previous updates. Updating is not required for the continued functioning of MathWorks Service Host or the MathWorks products it supports.

## Frequently Asked Questions

### Q: Is MathWorks Service Host required when I need to run batch MATLAB jobs?
MathWorks Service Host is not currently required when you use MATLAB with [-batch mode](https://mathworks.com/help/matlab/ref/matlabwindows.html). MathWorks Service Host is also not required for the worker nodes when you use MATLAB Parallel Server.

### Q: Is MathWorks Service Host expected to be running even if I am not using MATLAB?
MathWorks Service Host keeps running even after you stop MATLAB in order to handle background tasks efficiently. The MathWorks Service Host processes have been designed to be lightweight and to require minimum resources so that they do not impact your system's performance.

### Q: Are MathWorks Service Host updates installing any MATLAB updates?
No, MathWorks Service Host updates do not update your MATLAB. For more details about MATLAB updates, see [MATLAB Updates: Frequently Asked Questions](https://www.mathworks.com/support/faq/mathworks-update-notifications.html)

### Q: How can I disable auto-updates of MathWorks Service Host?
The only way to disable auto-updates of MathWorks Service Host is to install the configuration which supports alternative installation locations and remove the previous auto-updating versions using the scripts in [admin-scripts](./admin-scripts). New versions of MathWorks Service Host should then be installed manually.

### Q: If I disable auto-updates of MathWorks Service Host, how can I be notified of new releases that address bugs and security issues?
To be notified of new releases of MathWorks Service Host, you can subscribe to releases in this repository.

### Q: Which is the minimum version of MathWorks Service Host that I can use with my MATLAB?

| MATLAB Release | Minimum Version |
|---|---|
| R2024a | 2024.2.0.3 |
| R2024b | 2024.7.0.6 |
| R2025a | 2025.2.2.1 |
| R2025b | 2025.8.1.1 |
| R2026a | 2026.1.1.2 |

### Q: Which is the maximum version of MathWorks Service Host that I can use with my operating system?
The following tables show the maximum compatible version of MathWorks Service Host for each operating system version.

#### Windows

| OS Version | Maximum Version |
|---|---|
| Windows Vista | 2023.2 |
| Windows 7 | 2023.2 |
| Windows 8 | 2023.2 |
| Windows 8.1 | 2023.2 |
| Windows Server 2008 | 2023.2 |
| Windows Server 2008 R2 | 2023.2 |
| Windows Server 2012 | 2023.2 |
| Windows Server 2012 R2 | 2023.2 |
| All later versions | Latest |

#### Linux

| OS Version | Maximum Version |
|---|---|
| RHEL 7 | 2024.6 |
| Any distribution with glibc 2.17 | 2024.6 |
| All later versions | Latest |

#### macOS (Apple Silicon)

| OS Version | Maximum Version |
|---|---|
| 11 (Big Sur) | 2024.6 |
| 12 (Monterey) | 2025.11 |
| 13.0 - 13.2 (Ventura) | 2025.11 |
| All later versions | Latest |

#### macOS (Intel)

| OS Version | Maximum Version |
|---|---|
| 10.15 (Catalina) | 2024.6 |
| 11 (Big Sur) | 2024.6 |
| 12 (Monterey) | 2025.11 |
| 13.0 – 13.2 (Ventura) | 2025.11 |
| 13.3 – 13.7 (Ventura) | 2026.5 |
| 14 (Sonoma) | 2026.5 |
| 15 (Sequoia) | 2026.5 |
| 26 (Tahoe) | 2026.5 |

## Feedback
We encourage you to try this repository with your environment and provide feedback. If you encounter a technical issue or have an enhancement request, create an issue [here](https://github.com/mathworks-ref-arch/administer-mathworks-service-host/issues).

----

Copyright 2024 The MathWorks, Inc.

----
