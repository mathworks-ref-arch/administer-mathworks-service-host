
# Download and Install MathWorks Service Host in a custom location for Linux

These instructions are intended for administering MathWorks&reg; Service Host on Linux&reg;. To replace the default auto-updating version of MathWorks Service Host, run the three steps shown below in sequence. After removing the auto-updated versions, you must update MathWorks Service Host by running steps 1 and 2 when a new release is available. This repository will be updated to reflect the new releases of MathWorks Service Host and notify all the subscribers.

>Note: For more details about the following scripts and their available options, run them with `--help` option, e.g. `./download_msh.sh --help`

## 1. Download MathWorks Service Host
Download the MathWorks Service Host zip file from the MathWorks website using this command:
```bash
./download_msh.sh --destination /tmp/Downloads/MathWorks/ServiceHost
```
If you would like to inspect MathWorks Service Host or run security tools on it first, you can extract the zip file to obtain the MathWorks Service Host installation. Once any inspection/testing is complete, place the zip file in a network location which is accessible to the end user machines (for example, say you place it at `/Shared/Software/MathWorks/ServiceHost`).

## 2. Install MathWorks Service Host on End User Machines
To install MathWorks Service Host to the desired location on the end user machine, you can run the following (with elevated privileges if needed):
```bash
sudo ./install_msh.sh --source /Shared/Software/MathWorks/ServiceHost/ --destination /usr/local/MathWorks/ServiceHost/
```

You need to set the set the environment variable `MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT` for all users on the end user machines who intend to use MathWorks products. This environment variable should be set to the MathWorks Service Host installation root (in this example, `MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT=/usr/local/MathWorks/ServiceHost/`).

One way to achieve this is to use the `--update-environment` flag with the `ìnstall_msh.sh` script to set this as a system environment variable. It does this by adding/updating the variable in `/etc/environment`. If the `--update-environment` flag is not specified, you will be prompted to choose whether to update this variable in `/etc/environment` during installation, unless the `--no-update-environment` option is used.

>Note: If the environment variable is not set, MATLAB&reg; will install/use MathWorks Service Host in the default location in `$HOME`.

## 3.  Remove MathWorks Service Host installations from the default location
To remove MathWorks Service Host installations from the default location for the current user, you can run:
```bash
./cleanup_default_msh_installation_location.sh
```

To clean up all MathWorks Service Host installations in the default location for all users, run this command:
```bash
./cleanup_default_msh_installation_location.sh --for-all-users
```

>Note: Deleting MathWorks Service Host from the default installation location assumes that:
> 1. You have installed MathWorks Service Host to a custom location
> 2. You have set the environment variable `MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT` to that custom installation location for all users who may be running MathWorks products.

>Note: The above scripts work only for MATLAB releases starting from R2024a Update 6.

## Note: Updating MathWorks Service Host
The scripts in this repository will be updated every four weeks to reflect the newer release of MathWorks Service Host. Administrators who are managing MathWorks Service Host installations in custom locations should keep those installations up-to-date. To be notified of new releases of MathWorks Service Host, you can subscribe to releases in this repository.

# Feedback
We encourage you to try this repository with your environment and provide feedback. If you encounter a technical issue or have an enhancement request, create an issue [here](https://github.com/mathworks-ref-arch/administer-mathworks-service-host/issues).

----

Copyright 2024 The MathWorks, Inc.

----
