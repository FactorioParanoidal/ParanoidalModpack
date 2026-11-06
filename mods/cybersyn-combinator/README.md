# Cybersyn Combinator

[![Build status][build-badge]][build]
[![Latest release][release-badge]][release]
[![Version on mod portal][mod-portal-ver-badge]][mod]
[![Factorio version][factorio-ver-badge]][mod]

A mod for Factorio that adds a special combinator for use with the [Project Cybersyn][cybersyn] mod.

For more information on the mod features, check out the [information file](src/information.md).
(The text in the information file is what's used for the mod portal description.)

## Usage

 1. Install mod
 2. Craft the new "Cybersyn constant combinator"
 3. Place it like you would a regular constant combinator
 4. Configure the signals in it
 5. Hook it up to a Cybernetic combinator from [the Project Cybersyn mod][cybersyn]
 6. You're done!

## Development

 1. Clone repo somewhere.
 2. Symlink to the `src` folder from your Factorio mods folder

    Linux example:

    ```sh
    ln -s ~/repos/github.com/Sharparam/cybersyn-combinator/src ~/factorio/mods/cybersyn-combinator
    ```

    Windows example (powershell):

    ```pwsh
    New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\factorio\mods\cybersyn-combinator" -Value "$env:USERPROFILE\repos\github.com\Sharparam\cybersyn-combinator\src"
    ```
  3. Open the repo folder in VS Code or your favourite editor
  4. Hack away!

See the [CONTRIBUTING][] document for more information on developing/contributing!

## Acknowledgements

A lot was gained from looking at how the [LTN Combinator Modernized][ltnc] mod does things, so big thanks are due to that mod for getting up and running with the Cybersyn version.

## License

Copyright © 2023-2025 by [Adam Hellberg][sharparam].

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

[mod]: https://mods.factorio.com/mod/cybersyn-combinator
[mod-portal-ver-badge]: https://img.shields.io/badge/dynamic/json.svg?label=mod%20portal&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2Fcybersyn-combinator&query=%24.releases%5B-1%3A%5D.version&colorB=%23a87723
[factorio-ver-badge]: https://img.shields.io/badge/dynamic/json.svg?label=factorio%20version&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2Fcybersyn-combinator&query=%24.releases%5B-1%3A%5D.info_json.factorio_version&colorB=%23a87723
[build-badge]: https://github.com/Sharparam/cybersyn-combinator/actions/workflows/build.yml/badge.svg
[build]: https://github.com/Sharparam/cybersyn-combinator/actions/workflows/build.yml
[release-badge]: https://img.shields.io/github/v/release/Sharparam/cybersyn-combinator
[release]: https://github.com/Sharparam/cybersyn-combinator/releases/latest

[sharparam]: https://sharparam.com
[cybersyn]: https://mods.factorio.com/mod/cybersyn
[ltnc]: https://mods.factorio.com/mod/LTN_Combinator_Modernized
[contributing]: https://github.com/Sharparam/cybersyn-combinator/blob/main/CONTRIBUTING.md
