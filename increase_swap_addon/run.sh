#!/command/with-contenv bashio
# shellcheck shell=bash

set -e

SWAP_SIZE=$(bashio::config 'swap_size')
SWAP_LOCATION=$(bashio::config 'swap_location')
SWAP_FILE="${SWAP_LOCATION}/_swap.swap"

possible_locations=("addons" "media" "share" "backup")

remove_old_swap_file() {
  for location in "${possible_locations[@]}"; do
    if [ "${location}" != "${SWAP_LOCATION}" ]; then
      old_swap_file="/${location}/_swap.swap"
      if [ -f "${old_swap_file}" ]; then
        print_date "Removing old swap file at ${old_swap_file}..."
        swapoff "${old_swap_file}"
        rm -f "${old_swap_file}"
        print_date "Old swap file removed."
      fi
    fi
  done
}

print_date() {
  timestamp=$(date +'%H:%M:%S %d/%m/%Y')
  echo "[$timestamp] $1"
}

print_date "Starting Increase Swap add-on..."
print_date "Checking swap size at ${SWAP_LOCATION}..."

remove_old_swap_file

if [ ! -f "${SWAP_FILE}" ]; then
  print_date "Creating new swap file of ${SWAP_SIZE}M..."
  fallocate -l "${SWAP_SIZE}M" "${SWAP_FILE}"
  mkswap "${SWAP_FILE}"
  chmod 0600 "${SWAP_FILE}"
  swapon "${SWAP_FILE}"
  print_date "New swap file created and enabled."
else
  CURRENT_SWAP_SIZE=$(($(stat -c%s "${SWAP_FILE}") / (1024 * 1024)))
  if [ "${CURRENT_SWAP_SIZE}" -ne "${SWAP_SIZE}" ]; then
    print_date "Resizing swap file from ${CURRENT_SWAP_SIZE}M to ${SWAP_SIZE}M..."
    swapoff "${SWAP_FILE}"
    fallocate -l "${SWAP_SIZE}M" "${SWAP_FILE}"
    mkswap "${SWAP_FILE}"
    swapon "${SWAP_FILE}"
    print_date "Swap file resized and enabled."
  elif [[ ! $(dmesg | grep _swap.swap) = *swap\ on* ]]; then
    print_date "Swap file exists but not enabled. Enabling swap file..."
    mkswap "${SWAP_FILE}"
    swapon "${SWAP_FILE}"
    print_date "Existing swap file enabled."
  else
    print_date "Swap file already enabled. Refreshing swap file..."
    swapoff "${SWAP_FILE}"
    swapon "${SWAP_FILE}"
    print_date "Swap file refreshed and enabled."
  fi
fi
