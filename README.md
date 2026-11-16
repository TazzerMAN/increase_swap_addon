# Increase Swap for Home Assistant OS

[![Add this repository to your Home Assistant instance](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FTazzerMAN%2Fincrease_swap_addon)

A Home Assistant app (formerly add-on) that adds a swap file to Home Assistant OS.
It was written for Raspberry Pi boards, where 1 to 4 GB of RAM fill up quickly,
and works on any 64-bit Home Assistant OS installation (`aarch64`, `amd64`).

## Apps in this repository

- [Increase Swap](increase_swap_addon/README.md): creates, resizes and enables a
  swap file of the size and in the folder you choose.

## Installation

1. Click the button above, or go to **Settings > Apps > App store**, open the
   menu in the top right corner, choose **Repositories** and add
   `https://github.com/TazzerMAN/increase_swap_addon`.
2. Install **Increase Swap**, set its options, then start it.

See the [documentation](increase_swap_addon/DOCS.md) for the options and
the troubleshooting guide.

## Credits

Thanks to JZhass for the [original tip](https://community.home-assistant.io/t/how-to-increase-the-swap-file-size-on-home-assistant-os/272226).
