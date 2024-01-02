# Increase Swap Add-on for Home Assistant Operating System (HAOS)

This add-on increases the swap space on your system initially created for Rasberry Pi.  
You can configure the size and location of the swap file via the Home Assistant interface.

## Installation

1. Navigate to the Supervisor panel in your Home Assistant instance.
2. Click on the "Add-on store" tab.
3. Add the repository URL for this add-on.
4. Install the "Increase Swap" add-on.

## Configuration

Before starting the add-on, configure the desired swap size and location in the add-on's configuration panel. The default values are:

- swap_size: 2048 (2 GB)
- swap_location: "/backup"

## Add-on Behavior

Once the add-on is installed, make sure to leave the "Start on boot" option enabled. The add-on will run at startup and then stop, which is normal.  
Its purpose is to check if the swap file exists; if not, it creates the swap file and instructs the system to use it. If the swap file already exists, the add-on ensures that the system uses it.  
You can check the add-on logs to confirm that the process has completed successfully.

## Credits

Thanks to JZhass for the [tip](https://community.home-assistant.io/t/how-to-increase-the-swap-file-size-on-home-assistant-os/272226)!
