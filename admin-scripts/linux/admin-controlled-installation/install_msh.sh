#!/bin/bash

# Copyright 2024-2026 The MathWorks, Inc.

# Exit if any command fails
set -e
# Path from the working directory to the script's parent
parent_path=${0%/*}

# Utility method to print usage details and fail
print_usage_details_and_exit() {
    printf "$(<"$parent_path/man/install_msh.txt")\n" 1>&2
    exit 1
}

awk_based_envsubst() {
  local file="$1"
  awk '{
    line = $0
    while (match(line, /\$[A-Za-z_][A-Za-z0-9_]*/)) {
      var = substr(line, RSTART + 1, RLENGTH - 1)
      val = ENVIRON[var]
      line = substr(line, 1, RSTART - 1) val substr(line, RSTART + RLENGTH)
    }
    print line
  }' "$file"
}

# Define warning messages
declare -A warning_messages
warning_messages[0]=$(awk_based_envsubst "$parent_path/man/install_msh_warning_0.txt")
warning_messages[1]=$(awk_based_envsubst "$parent_path/man/install_msh_warning_1.txt")

# Parse the provided arguments
release_number=$(tr -d '[:space:]' < "$parent_path/latest_release.txt")
update_environment=0
no_update_environment=0
download_directory_specified=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --release)
            release_number="$2"
            # Remove the starting v if it exists
            if [[ "$release_number" == v* ]]; then
                release_number="${release_number#v}"
            fi
            shift 2
            ;;
        --source)
            download_directory_specified=1
            download_directory=$(realpath "$2")
            shift 2
            ;;
        --destination)
            installation_directory="$2"
            if [ ! -d "$installation_directory" ]; then
                mkdir -p "$installation_directory"
            fi
            installation_directory=$(realpath "$installation_directory")
            shift 2
            ;;
        --update-environment)
            update_environment=1
            shift 1
            ;;
        --no-update-environment)
            no_update_environment=1
            shift 1
            ;;
        --help)
            print_usage_details_and_exit
            ;;
        *)
            echo "ERROR: Unknown option: $1"
            print_usage_details_and_exit
            ;;
    esac
done

# Check installation_directory is provided
if [ -z "$installation_directory" ]; then
    echo "ERROR: Specify the destination directory for the installation."
    print_usage_details_and_exit
fi

downloaded_zip_file="$download_directory/managed_mathworksservicehost_${release_number}_package_glnxa64.zip"
if [ "$download_directory_specified" -eq 1 ]; then
    if [[ ! -f "$downloaded_zip_file" ]]; then
        # Error if the download_directory is provided and does not include the expected zip
        printf "ERROR: The specified source directory does not contain the expected zip file:\n"
        printf "\t $downloaded_zip_file\n"
        exit 1
    fi
else
    # If no download_directory is specified, use the default after downloading the installer into it
    download_directory="$HOME/.MathWorks/ServiceHost/tmpZip"
    if [ ! -d "$download_directory" ]; then
        mkdir -p "$download_directory"
    fi
    downloaded_zip_file="$download_directory/managed_mathworksservicehost_${release_number}_package_glnxa64.zip"
    download_url="https://ssd.mathworks.com/supportfiles/downloads/MathWorksServiceHost/v$release_number/release/glnxa64/managed_mathworksservicehost_${release_number}_package_glnxa64.zip"
    curl -o "$downloaded_zip_file" "$download_url"
fi

# Extract the zip into the desired location, replacing any existing installation of the same version
versioned_installation_dir="$installation_directory/v$release_number"
mkdir -p "$versioned_installation_dir"
unzip -qo "$downloaded_zip_file" -d "$versioned_installation_dir"

# Cleanup the default download directory if used
if [ "$download_directory_specified" -eq 0 ]; then
    rm -rf $download_directory
fi

# Create/Update the LatestInstall.info file in the installation directory
latest_install_info_file_path="$installation_directory/LatestInstall.info"
{
    echo "LatestDSInstallerVersion $release_number"
    echo "LatestDSInstallRoot $versioned_installation_dir"
    echo "DSLauncherExecutable $versioned_installation_dir/bin/glnxa64/MathWorksServiceHost"
} > "$latest_install_info_file_path"

# Stop any processes which may be running from default installations
pkill -f MATLABConnector 2>/dev/null || true
pkill -f "MathWorksServiceHost client" 2>/dev/null || true
pkill -f "MathWorksServiceHost-Monitor" 2>/dev/null || true
pkill -f "MathWorksServiceHost service" 2>/dev/null || true


# Utility for checking if this is the first install of msh
actual_user="$SUDO_USER"
actual_home="$(getent passwd "$actual_user" | cut -d: -f6)"
no_other_installations_found () {
    if find "$installation_directory" -maxdepth 1 -name 'v20*' -type d ! -name "v$release_number" | grep -q .; then
        return 0 # Another admin controlled installation was found
    fi

    if find "$actual_home/.MathWorks/ServiceHost/-mw_shared_installs/" -maxdepth 1 -name 'v20*' -type d | grep -q .; then
        return 0 # A previous default installation was found
    fi

    return 1
}

# Create or update autostart files depending on whether this is the first install or not
msh_autostart_file_path="$actual_home/.config/autostart/mathworks-service-host.desktop"
if no_other_installations_found ; then
    # This is the first installation, activate autostart by default
    {
        echo "[Desktop Entry]"
        echo "Type=Application"
        echo "Name=Mathworks Service Host"
        echo "Exec=$versioned_installation_dir/bin/glnxa64/MathWorksServiceHost service --realm-id companion@prod@production"
        echo "Terminal=false"
    } > "$msh_autostart_file_path"
else
    # Another installation was found. Honor the users preferences and update autostart files only if they exist
    if [ -f "$msh_autostart_file_path" ]; then
        {
            echo "[Desktop Entry]"
            echo "Type=Application"
            echo "Name=Mathworks Service Host"
            echo "Exec=$versioned_installation_dir/bin/glnxa64/MathWorksServiceHost service --realm-id companion@prod@production"
            echo "Terminal=false"
        } > "$msh_autostart_file_path"
    fi

    matlab_connector_autostart_file_path="$actual_home/.config/autostart/matlab-drive-connector.desktop"
    if [ -f "$matlab_connector_autostart_file_path" ]; then
        {
            echo "[Desktop Entry]"
            echo "Type=Application"
            echo "Name=MATLAB Connector"
            echo "Exec=$versioned_installation_dir/bin/MATLABConnector start"
            echo "Terminal=false"

        } > "$matlab_connector_autostart_file_path"
    fi
fi

# Remove any previously installed versions of MathWorks Service Host
find "$installation_directory" -maxdepth 1 -name 'v202*' -type d ! -name "v$release_number" -exec rm -rf {} +

# Print warnings if MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT is not set
ev="$MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT"
if [[ -z $ev ]]; then
    printf "${warning_messages[0]}\n"
else
    if [ ! -d "$ev" ]; then
        mkdir -p "$ev"
    fi
    ev_installation_directory=$(realpath "$ev")
    if [[ "$ev_installation_directory" != "$installation_directory" ]]; then
        printf "${warning_messages[1]}\n"
    fi
fi

# Utility for updating etc/environment file
update_etc_environment() {
    updated_entry="MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT=$installation_directory"
    if grep -q '^MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT=' /etc/environment; then
        sed -i '/^MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT=/c\'"$updated_entry" /etc/environment

    else
        echo "" >> /etc/environment
        echo "$updated_entry" >> /etc/environment
    fi
}

# Update the /etc/environment file to include MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT if the user agrees
if [ "$update_environment" -eq 1 ] && [ "$no_update_environment" -eq 0 ]; then
    update_etc_environment
elif [ "$update_environment" -eq 0 ] && [ "$no_update_environment" -eq 1 ]; then
    printf "Skipping update of /etc/environment.\n"
elif ! grep -Fxq "MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT=$installationDirectory" /etc/environment; then
    read -p "Would you like to update /etc/environment to set MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT system wide? (Y/n): " response
    response=${response:-Y}
    case "$response" in
        [yY][eE][sS]|[yY])
            update_etc_environment
            ;;
        [nN][oO]|[nN]|"")
            printf "Skipping update of /etc/environment.\n"
            ;;
        *)
            printf "Unknown option, will not update /etc/environment.\n"
            ;;
    esac
fi

printf "MathWorks Service Host has been installed in $installation_directory\n"

exit 0
