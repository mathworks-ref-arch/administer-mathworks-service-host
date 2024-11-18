#!/bin/bash

# Copyright 2024 The MathWorks, Inc.

# Exit if any command fails
set -e
# Path from the working directory to the script's parent
parent_path=${0%/*}

# Utility method to print usage details and exit
print_usage_details_and_exit() {
    printf "$(<"$parent_path/man/download_msh.txt")\n" 1>&2
    exit 1
}

# Parse the provided arguments
release_number=$(tr -d '[:space:]' < "$parent_path/latest_release.txt")
release_specified=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --release)
            release_specified=1
            release_number="$2"
            if [[ "$release_number" == v* ]]; then
                release_number="${release_number#v}"
            fi
            shift 2
            ;;
        --destination)
            download_directory="$2"
            # Make sure the download_directory exist
            if [ ! -d "$download_directory" ]; then
                mkdir -p "$download_directory"
            fi
            download_directory=$(realpath "$download_directory")
            shift 2
            ;;
        --help)
            print_usage_details_and_exit
            ;;
        *)
            echo "Unknown option: $1"
            print_usage_details_and_exit
            ;;
    esac
done

# Check installation_directory is provided
if [ -z "$download_directory" ]; then
    echo "ERROR: Specify the destination directory for the download."
    print_usage_details_and_exit
fi

# Download the specified release
download_url="https://ssd.mathworks.com/supportfiles/downloads/MathWorksServiceHost/v$release_number/release/glnxa64/managed_mathworksservicehost_${release_number}_package_glnxa64.zip"
download_zip_file="$download_directory/managed_mathworksservicehost_${release_number}_package_glnxa64.zip"
curl -o "$download_zip_file" "$download_url"

# Print the next steps needed for the installation
M=""
M="${M}The MathWorks Service Host zip file has been downloaded in:"
M="${M}\n\t $download_directory"
M="${M}\n\t In order to install it you can run:"
M="${M}\n\t ./install_msh.sh"
if [ "$release_specified" -eq 1 ]; then
    M="${M} --release $release_number"
fi
M="${M} --source $download_directory --destination <installation_directory>\n"
printf "${M}"
exit 0
