
# Download and Install MathWorks Service Host in a custom location for Linux

These instructions are intended for administering MathWorks&reg; Service Host on Linux&reg;. Administrators who are managing MathWorks Service Host installations in custom locations must keep these installations up-to-date. To be notified of new releases of MathWorks Service Host, subscribe to releases in this repository.

>Note: The below scripts work only for MATLAB releases starting from **R2024a Update 6**.

### Switching to an administrator-controlled installation of MathWorks Service Host
To switch from the default, auto-updating version of MathWorks Service Host to an adminstrator-controlled installation in a custom location, download a copy of this repository and run all three steps shown below in sequence.
### Updating an administrator-controlled installation of MathWorks Service Host
After switching to an administrator-controlled installation of MathWorks Service Host, you must update it when a new version is available. You can do this by downloading a copy of the latest version of this repository and running steps 1 and 2 below. If the destination argument in the `install_msh.sh` script (step 2) is the same as that of your previous installation, the script automatically cleans up the previously installed version of MathWorks Service Host. If the destination argument is different, ensure to clean up the old installation, as the script will not be able to find it and clean it up.

>Note: For more details about the following scripts and their available options, run them with `--help` option, e.g. `./download_msh.sh --help`

## 1. Download MathWorks Service Host
Download the MathWorks Service Host zip file from the [MathWorks website](https://ssd.mathworks.com/supportfiles/downloads/MathWorksServiceHost/v2025.10.0.2/release/glnxa64/managed_mathworksservicehost_2025.10.0.2_package_glnxa64.zip) or by using this command:
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

One way to achieve this is to use the `--update-environment` flag with the `install_msh.sh` script to set this as a system environment variable. It does this by adding/updating the variable in `/etc/environment`. If the `--update-environment` flag is not specified, you will be prompted to choose whether to update this variable in `/etc/environment` during installation, unless the `--no-update-environment` option is used.

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


# Feedback
We encourage you to try this repository with your environment and provide feedback. If you encounter a technical issue or have an enhancement request, create an issue [here](https://github.com/mathworks-ref-arch/administer-mathworks-service-host/issues).

----

Copyright 2024-2025 The MathWorks, Inc.

----
