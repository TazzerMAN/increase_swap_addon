#!/command/with-contenv bashio
# shellcheck shell=bash
# Creates, resizes or enables the swap file, then exits.

readonly SWAP_NAME="_swap.swap"
readonly TEMP_SWAP_NAME="_temp_swap.swap"
readonly LOCATIONS=("addons" "media" "share" "backup")
# Free space kept on the disk after the swap file, so Home Assistant keeps working.
readonly SPACE_MARGIN_MB=512
# Path of the swap file in use, so a change of location or folder can clean it up.
readonly STATE_FILE="/data/swap_file"

SWAP_SIZE=$(bashio::config 'swap_size')
SWAP_LOCATION=$(bashio::config 'swap_location')
SWAP_FOLDER=""
if bashio::config.has_value 'swap_folder'; then
  SWAP_FOLDER=$(bashio::config 'swap_folder')
  SWAP_FOLDER="${SWAP_FOLDER#/}"
  SWAP_FOLDER="${SWAP_FOLDER%/}"
fi
if [[ "/${SWAP_FOLDER}/" == *"/../"* ]]; then
  bashio::exit.nok "swap_folder must stay inside ${SWAP_LOCATION}: '..' is not allowed."
fi
SWAP_DIR="/${SWAP_LOCATION}${SWAP_FOLDER:+/${SWAP_FOLDER}}"
SWAP_FILE="${SWAP_DIR}/${SWAP_NAME}"
TEMP_SWAP_SIZE=$((SWAP_SIZE / 2))
TEMP_SWAP_FILE="${SWAP_DIR}/${TEMP_SWAP_NAME}"

free_space_mb() {
  df -Pm "$1" | awk 'NR == 2 { print $4 }'
}

require_free_space() {
  local needed_mb=$1
  local free_mb
  free_mb=$(free_space_mb "${SWAP_DIR}")
  if ((free_mb < needed_mb + SPACE_MARGIN_MB)); then
    bashio::exit.nok "Not enough free space in ${SWAP_DIR}: ${free_mb} MB free, ${needed_mb} MB needed plus a ${SPACE_MARGIN_MB} MB safety margin. Lower swap_size or free some space."
  fi
}

# Disables a swap file; "Invalid argument" means it was not active, which is fine.
disable_swap() {
  local output
  if output=$(swapoff "$1" 2>&1) || [[ "${output}" == *"Invalid argument"* ]]; then
    return 0
  fi
  bashio::log.error "${output}"
  return 1
}

# Enables a swap file; "busy" means the kernel already uses it.
enable_swap() {
  local output
  if output=$(swapon "$1" 2>&1); then
    return 0
  fi
  if [[ "${output}" == *"busy"* ]]; then
    bashio::log.info "${1} is already in use as swap."
    return 0
  fi
  bashio::log.error "${output}"
  return 1
}

create_swap() {
  local file=$1 size_mb=$2
  bashio::log.info "Creating ${file} (${size_mb} MB)..."
  if ! fallocate -l "${size_mb}M" "${file}" 2>/dev/null; then
    bashio::log.warning "fallocate is not supported here, writing the file with dd (slower)."
    if ! dd if=/dev/zero of="${file}" bs=1M count="${size_mb}" status=none; then
      rm -f "${file}"
      bashio::exit.nok "Could not write ${file}."
    fi
  fi
  chmod 0600 "${file}"
  if ! mkswap "${file}" >/dev/null; then
    rm -f "${file}"
    bashio::exit.nok "mkswap failed on ${file}."
  fi
  enable_swap "${file}" || bashio::exit.nok "Could not enable ${file}."
}

remove_swap() {
  disable_swap "$1" || return 1
  rm -f "$1"
}

remove_previous_swap_files() {
  local candidates=() location file
  for location in "${LOCATIONS[@]}"; do
    candidates+=("/${location}/${SWAP_NAME}" "/${location}/${TEMP_SWAP_NAME}")
  done
  if [[ -f "${STATE_FILE}" ]]; then
    file=$(<"${STATE_FILE}")
    candidates+=("${file}" "$(dirname "${file}")/${TEMP_SWAP_NAME}")
  fi
  for file in "${candidates[@]}"; do
    [[ "${file}" == "${SWAP_FILE}" || "${file}" == "${TEMP_SWAP_FILE}" || ! -f "${file}" ]] && continue
    bashio::log.info "Removing ${file} left by a previous location..."
    remove_swap "${file}" ||
      bashio::log.warning "Kept ${file}: it is still in use, it will be removed on a later start."
  done
}

bashio::log.info "Swap file: ${SWAP_FILE}, requested size: ${SWAP_SIZE} MB."

# Never create the folder: on an unplugged drive it would land on the data disk.
if [[ ! -d "${SWAP_DIR}" ]]; then
  bashio::exit.nok "${SWAP_DIR} does not exist. For an external drive, check that it is plugged in and listed under /media."
fi

remove_previous_swap_files

# A temporary file only survives an interrupted resize.
if [[ -f "${TEMP_SWAP_FILE}" ]]; then
  bashio::log.info "Removing ${TEMP_SWAP_FILE} left by an interrupted resize..."
  remove_swap "${TEMP_SWAP_FILE}" || bashio::exit.nok "Could not disable ${TEMP_SWAP_FILE}."
fi

if [[ ! -f "${SWAP_FILE}" ]]; then
  require_free_space "${SWAP_SIZE}"
  create_swap "${SWAP_FILE}" "${SWAP_SIZE}"
  bashio::log.info "Swap file created and enabled."
else
  CURRENT_SWAP_SIZE=$(($(stat -c%s "${SWAP_FILE}") / 1024 / 1024))
  if ((CURRENT_SWAP_SIZE != SWAP_SIZE)); then
    bashio::log.info "Resizing from ${CURRENT_SWAP_SIZE} MB to ${SWAP_SIZE} MB."
    GROWTH=$((SWAP_SIZE > CURRENT_SWAP_SIZE ? SWAP_SIZE - CURRENT_SWAP_SIZE : 0))
    require_free_space $((TEMP_SWAP_SIZE + GROWTH))
    # The temporary swap holds the pages moved out of the old file during swapoff.
    create_swap "${TEMP_SWAP_FILE}" "${TEMP_SWAP_SIZE}"
    if ! remove_swap "${SWAP_FILE}"; then
      remove_swap "${TEMP_SWAP_FILE}"
      bashio::exit.nok "The current swap file is too full to be released; it was kept as is. Retry when memory use is lower, or restart the host."
    fi
    create_swap "${SWAP_FILE}" "${SWAP_SIZE}"
    remove_swap "${TEMP_SWAP_FILE}" || bashio::log.warning "${TEMP_SWAP_FILE} is still in use, it will be removed on the next start."
    bashio::log.info "Swap file resized and enabled."
  else
    enable_swap "${SWAP_FILE}" || bashio::exit.nok "Could not enable ${SWAP_FILE}."
    bashio::log.info "Swap file enabled."
  fi
fi

echo "${SWAP_FILE}" >"${STATE_FILE}"

bashio::log.info "Active swap:"
cat /proc/swaps
