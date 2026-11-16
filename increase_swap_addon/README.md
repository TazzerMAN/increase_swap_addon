# Home Assistant App: Increase Swap

Adds a swap file to Home Assistant OS, so a board with little RAM (a Raspberry
Pi for instance) keeps running when memory gets tight.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

The app runs at startup, makes sure the swap file exists with the size you
chose and is enabled, then stops. Seeing it stopped afterwards is expected.

See the **Documentation** tab for the options.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
