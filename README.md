# Administer MathWorks Service Host

MathWorks&reg; Service Host is a collection of background processes that provide required services to MATLAB&reg; and other MathWorks products. Starting from MATLAB Release 2024a, MATLAB requires MathWorks Service Host. MathWorks Service Host processes run in the background even when other MathWorks products are closed, but they are designed to be lightweight and to not affect system performance.

By default, MathWorks Service Host is installed to the `%LOCALAPPDATA%\MathWorks` or `$HOME/MathWorks` directory of each user's machine, and it automatically updates to the latest version when a new one is available. A new version of MathWorks Service Host is released every four weeks. One installation of MathWorks Service Host supports all versions of MATLAB.

If you need more control over where MathWorks Service Host is installed, and when it is updated, you can use the scripts in the [admin-scripts](./admin-scripts) folder. These scripts allow you to install a configuration of MathWorks Service Host which supports alternative installation locations and does not attempt to automatically update itself. These scripts will be updated every four weeks to reflect each new release of MathWorks Service Host. Administrators using this configuration should keep their installations of MathWorks Service Host up-to-date. To be notified of new releases of MathWorks Service Host, you can subscribe to releases in this repository.

## Frequently Asked Questions

### Q: Is MathWorks Service Host required when I need to run batch MATLAB jobs?
MathWorks Service Host is not currently required when you use MATLAB with [-batch mode](https://mathworks.com/help/matlab/ref/matlabwindows.html). MathWorks Service Host is also not required for the worker nodes when you use MATLAB Parallel Server.

### Q: How can I disable auto-updates of MathWorks Service Host?
The only way to disable auto-updates of MathWorks Service Host is to install the configuration which supports alternative installation locations and remove the previous auto-updating versions using the scripts in [admin-scripts](./admin-scripts). New versions of MathWorks Service Host should then be installed manually.

### Q: Is MathWorks Service Host expected to be running even if I am not using MATLAB?
MathWorks Service Host keeps running even after you stop MATLAB in order to handle background tasks efficiently. The MathWorks Service Host processes have been designed to be lightweight and to require minimum resources so that they do not impact your system's performance.


## Feedback
We encourage you to try this repository with your environment and provide feedback. If you encounter a technical issue or have an enhancement request, create an issue [here](https://github.com/mathworks-ref-arch/administer-mathworks-service-host/issues).

----

Copyright 2024 The MathWorks, Inc.

----
