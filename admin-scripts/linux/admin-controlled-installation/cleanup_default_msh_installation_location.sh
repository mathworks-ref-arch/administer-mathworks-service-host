#!/bin/bash

# Copyright 2024 The MathWorks, Inc.

# Exit if any command fails
set -e
# Path from the working directory to the script's parent
parent_path=${0%/*}

# Utility method to print usage details and exit
print_usage_details_and_exit() {
    printf "$(<"$parent_path/man/cleanup_default_msh_installation_location.txt")\n" 1>&2
    exit 1
}

# Parse the provided arguments and get a first draft list of directories to clean up
excluding_regex="(?!a)a" # Never matching regex
excluding_regex_specified=0
force=0
# By default cleanup the installations of the current user
mapfile -t new_elements < <(find /home/$USER/.MathWorks/ServiceHost/*/v202* -mindepth 0 -maxdepth 0 -type l -print 2>/dev/null)
draft_directories=("${new_elements[@]}")
mapfile -t new_elements < <(find /home/$USER/.MathWorks/ServiceHost/*/v202* -mindepth 0 -maxdepth 0 -type d -print 2>/dev/null)
draft_directories+=("${new_elements[@]}")

while [[ $# -gt 0 ]]; do
    case "$1" in
        --excluding)
            excluding_regex_specified=1
            excluding_regex=$2
            shift 2
            ;;
        --for-all-users)
            # Overwrite the list to cleanup with the installations of all found users
            mapfile -t new_elements < <(find /home/*/.MathWorks/ServiceHost/*/v202* -mindepth 0 -maxdepth 0 -type l -print 2>/dev/null)
            draft_directories=("${new_elements[@]}")
            mapfile -t new_elements < <(find /home/*/.MathWorks/ServiceHost/*/v202* -mindepth 0 -maxdepth 0 -type d -print 2>/dev/null)
            draft_directories+=("${new_elements[@]}")
            shift 1
            ;;
        --force)
            force=1
            shift 1
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

# Filter out the directories that match the provided regular expression
directories_to_cleanup=()
if [ "$excluding_regex_specified" -eq 0 ]; then
    directories_to_cleanup=("${draft_directories[@]}")
else
    for element in "${draft_directories[@]}"; do
        if ! echo "$element" | grep -qP "$excluding_regex"; then
            directories_to_cleanup+=("$element")
        fi
    done
fi

# Return early if there is nothing to do
if [ "${#directories_to_cleanup[@]}" -eq 0 ]; then
    printf "No MathWorks Service Host installations found to cleanup.\n"
    exit 0
fi

# Utility for cleaning up all found directories
do_cleanup() {
    # Stop any processes which may be running from default installations
    pkill -f MATLABConnector 2>/dev/null || true
    pkill -f "MathWorksServiceHost client" 2>/dev/null || true
    pkill -f "MathWorksServiceHost-Monitor" 2>/dev/null || true
    pkill -f "MathWorksServiceHost service" 2>/dev/null || true

    # Remove all the identified MSH installations
    for element in "${directories_to_cleanup[@]}"; do
        element_parent="$(dirname "$element")"
        rm -rf "$element" || true # Notify the user in case a directory cannot be removed
        rmdir "$element_parent" 2>/dev/null || true # Try to remove the parent directory if it's empty
    done
}

# Cleanup if --force was set, else inform the user about the directories to be deleted and ask permission before proceeding
if [[ $force -eq 1 ]]; then
    printf "Cleaning up the following MathWorks Service Host installations:"
    for element in "${directories_to_cleanup[@]}"; do
        printf "\n\t $element"
    done
    do_cleanup
    printf "\nCleanup completed.\n"
else
    printf "Found the following MathWorks Service Host installations:"
    for element in "${directories_to_cleanup[@]}"; do
        printf "\n\t $element"
    done
    printf "\nDeleting all the above requires that:"
    printf "\n\t - you have installed MathWorks Service Host into a custom location, and"
    printf "\n\t - you have set the environment variable MATHWORKS_SERVICE_HOST_MANAGED_INSTALL_ROOT"
    printf "\n\t   to that custom installation path."
    printf "\n"
    read -p "Do you want to proceed? (y/N): " response
    response=${response:-N}
    case "$response" in
        [yY][eE][sS]|[yY])
            do_cleanup
            ;;
        [nN][oO]|[nN]|"")
            printf "Cancelling cleanup"
            ;;
        *)
            printf "Unknown option, cancelling cleanup"
            ;;
    esac
    printf "Cleanup completed.\n"
fi

exit 0
