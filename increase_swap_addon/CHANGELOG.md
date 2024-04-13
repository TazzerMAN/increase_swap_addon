# Changelog

## [1.2.0] - 2024-04-13

### Added
- Added temporary swap file support to ensure system stability during the swap file resizing process.
- Temporary swap file is set to half the size of the target swap size to optimize disk space usage.

### Changed
- Modified the swap file resizing process to include the temporary swap file for safer operation.
- Optimized swap file handling to increase the lifespan of storage media. Now, the script checks if the swap file exists and only performs `swapon` without recreating the swap file to avoid unnecessary write operations.

## [1.1.2] - 2024-01-02

### Fix
- Fixed the issue when the swap file has been already set off by adding error handling and log messages to provide clearer feedback.

### Added
- Improved the log messages to give more detailed feedback during swap file operations, including success and error messages.

## [1.1.1] - 2023-06-11

### Added
- Timestamp added to log messages to enhance debugging and monitoring.

## [1.1.0] - 2023-04-26

### Added
- Support for resizing the swap file when the configuration changes.
- Automatically remove old swap file when changing the swap location in the configuration.

## [1.0.0] - 2023-04-16

### Added
- Initial release of the Increase Swap Add-on for Home Assistant.
- Create and enable swap file based on user configuration.
- Configurable swap size and location via the Home Assistant interface.
