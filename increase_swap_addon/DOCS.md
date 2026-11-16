# Home Assistant App: Increase Swap

## How it works

Each time it starts, the app:

1. removes the swap file left in another folder after a change of
   `swap_location` or `swap_folder`;
2. creates the swap file if it does not exist, after checking that the disk
   has enough free space;
3. resizes it if `swap_size` changed, through a temporary swap file so the
   memory already swapped out is never lost;
4. enables it, then stops.

Keep **Start on boot** enabled: Home Assistant OS forgets the swap on every
reboot, and the app turns it back on.

## Options

### `swap_size`

Size of the swap file in MB, from 256 to 8192. Default: `2048`.

The disk must keep at least 512 MB free after the swap file is created,
otherwise the app stops with an error and changes nothing.

### `swap_location`

Folder that holds the swap file (`_swap.swap`): `backup`, `share`, `media` or
`addons` (the local apps folder). Default: `backup`.

All four folders sit on the Home Assistant OS data disk. Keep `backup` unless
you have a reason to change it: it is the only one that backups never
include. A swap file in `share`, `media` or `addons` is copied into every
backup that contains that folder, which adds gigabytes to each one.

### `swap_folder` (optional)

Subfolder of `swap_location` that holds the swap file. Use it to put the swap
on another drive: Home Assistant OS mounts USB drives under `media`, so a
drive labelled `usbdisk` is `swap_location: media` with `swap_folder: usbdisk`.

The folder must already exist; the app never creates it, so an unplugged drive
cannot silently move the swap back to the SD card. The drive needs a Linux
filesystem such as ext4: the kernel refuses swap files on exFAT or NTFS.
The free space check and its 512 MB margin then apply to that drive.

## Two swap areas are normal

Home Assistant OS has its own swap file (`/mnt/data/swapfile`, about a third
of the RAM). The app adds a second one, so the system lists both. Since Home
Assistant OS 15 you can also resize the built-in one from the command line
(`ha os config swap options --swap-size 2G`, then reboot); the app stays
useful to pick the size and location from the interface, without a reboot.

## Troubleshooting

- **The app stopped right after starting.** This is expected; its log ends
  with the list of active swap files.
- **"Not enough free space".** Lower `swap_size` or free some space on the
  data disk.
- **"The current swap file is too full to be released".** A resize needs to
  move the swapped out memory. Retry when the system is less busy, or reboot
  the host and start the app again.
- **The update to 1.4.0 or later never installs.** Those versions only run on
  64-bit Home Assistant OS. If **Settings > System > Repairs > System
  information** shows an `armv7` or `armhf` architecture, the installation is
  32-bit: Home Assistant stopped supporting it, and moving to the 64-bit
  image of Home Assistant OS (restoring a backup) is the way forward.

## Support

Open an issue on [GitHub](https://github.com/TazzerMAN/increase_swap_addon/issues).
