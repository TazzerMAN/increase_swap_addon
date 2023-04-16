#!/command/with-contenv bashio
# shellcheck shell=bash

SWAP_SIZE=$(bashio::config 'swap_size')
SWAP_LOCATION=$(bashio::config 'swap_location')
SWAP_FILE="${SWAP_LOCATION}/_swap.swap"

echo "Starting Increase Swap add-on..."
echo "Increasing swap size to ${SWAP_SIZE}M in ${SWAP_LOCATION}..."

# Create swap file
set -e

SWAP_SIZE=$(bashio::config 'swap_size')
SWAP_LOCATION=$(bashio::config 'swap_location')
SWAP_FILE="${SWAP_LOCATION}/_swap.swap"

if [ ! -f "${SWAP_FILE}" ]; then
  fallocate -l "${SWAP_SIZE}M" "${SWAP_FILE}"
  mkswap "${SWAP_FILE}"
  chmod 0600 "${SWAP_FILE}"
  swapon "${SWAP_FILE}"
  echo "SWAP_NEW_FILE_CREATED_USED"
elif [[ ! $(dmesg | grep _swap.swap) = *swap\ on* ]]; then
  mkswap "${SWAP_FILE}"
  swapon "${SWAP_FILE}"
  echo "SWAP_USING_OLD_FILE"
else
  swapoff "${SWAP_FILE}"
  swapon "${SWAP_FILE}"
  echo "SWAP_FINAL_ELSE_STATEMENT"
fi