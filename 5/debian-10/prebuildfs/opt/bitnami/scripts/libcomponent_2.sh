#!/bin/bash
#
# Library for managing Bitnami components

# Constants
CACHE_ROOT="/tmp/bitnami/pkg/cache"
DOWNLOAD_URL="https://downloads.mongodb.com/compass"

# Functions

########################
# Download and unpack a Bitnami package
# Globals:
#   OS_NAME
#   OS_ARCH
#   OS_FLAVOUR
# Arguments:
#   $1 - component's name
#   $2 - component's version
# Returns:
#   None
#########################
component_unpack() {
    local name="${1:?name is required}"
    local version="${2:?version is required}"
    local base_name="${name}-${version}-${OS_NAME}-x64"
    local package_sha256=""
    local directory="/opt/bitnami"

    # Validate arguments
    shift 2
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -c|--checksum)
                shift
                package_sha256="${1:?missing package checksum}"
                ;;
            *)
                echo "Invalid command line flag $1" >&2
                return 1
                ;;
        esac
        shift
    done

    echo "Downloading $base_name package"
    if [ -f "${CACHE_ROOT}/${base_name}.tgz" ]; then
        echo "${CACHE_ROOT}/${base_name}.tgz already exists, skipping download."
        cp "${CACHE_ROOT}/${base_name}.tgz" .
        rm "${CACHE_ROOT}/${base_name}.tgz"
        # if [ -f "${CACHE_ROOT}/${base_name}.tar.gz.sha256" ]; then
        #     echo "Using the local sha256 from ${CACHE_ROOT}/${base_name}.tar.gz.sha256"
        #     package_sha256="$(< "${CACHE_ROOT}/${base_name}.tar.gz.sha256")"
        #     rm "${CACHE_ROOT}/${base_name}.tar.gz.sha256"
        # fi
    else
	curl --remote-name --silent --show-error --fail "${DOWNLOAD_URL}/${base_name}.tgz"
    fi
    # if [ -n "$package_sha256" ]; then
    #     echo "Verifying package integrity"
    #     echo "$package_sha256  ${base_name}.tar.gz" | sha256sum --check - || exit "$?"
    # fi
    mkdir -p ${directory}/mongo/bin
    tar --directory "${directory}/mongo/bin" --extract --gunzip --file "${base_name}.tgz" --no-same-owner --strip-components=2
    rm "${base_name}.tgz"
    mkdir -p /.mongodb/mongosh
    chmod -R a+rw /.mongodb/mongosh
}
