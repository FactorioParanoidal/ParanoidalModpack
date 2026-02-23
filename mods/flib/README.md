[![shield](https://img.shields.io/badge/Ko--fi-Donate%20-hotpink?logo=kofi&logoColor=white)](https://ko-fi.com/raiguard)
[![shield](https://img.shields.io/badge/Crowdin-Translate-brightgreen)](https://crowdin.com/project/raiguards-factorio-mods)
[![shield](https://img.shields.io/badge/dynamic/json?color=orange&label=Factorio&query=downloads_count&suffix=%20downloads&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2Fflib)](https://mods.factorio.com/mod/flib)

# Factorio Library

The Factorio Library is a set of high-quality, commonly-used utilities for creating Factorio mods.

## Usage

Download the latest release from the [mod portal](https://mods.factorio.com/mod/flib) unzip it, and put it in your mods directory. You can access libraries provided by flib with `require("__flib__.position")`, etc.

Add the flib directory to your language server's library. We recommend installing the [Factorio modding toolkit](https://github.com/justarandomgeek/vscode-factoriomod-debug) and setting it up with the [Sumneko Lua language server](https://github.com/sumneko/lua-language-server) to get cross-mod autocomplete and type checking.

There is currently no online documentation due to a lack of infrastructure to generate it from EmmyLua annotations.

## Contributing

Please use the [Codeberg repository](https://codeberg.org/raiguard/flib) for questions, bug reports, or pull requests.

For locale contributions, please use [Crowdin](https://crowdin.com/project/raiguards-factorio-mods).
