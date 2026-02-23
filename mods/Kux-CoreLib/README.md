# Kuxynator's Core Library

Provides core functionality for Kuxynator's [Factorio](https://factorio.com/) [mods](https://mods.factorio.com/user/Kuxanytor).

[![CC VY-NC-BD](https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png)](Zhttps://creativecommons.org/licenses/by-nc-nd/4.0/)  
This work is licensed under a [Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License](https://creativecommons.org/licenses/by-nc-nd/4.0/).

## Public Library

module | short description
------|------------
[lua](#Lua) | Provides public functions missing in lua
[ModInfo](#ModInfo) | Provides information about the current mod
[String](#String) | Provides string functions
[Table](#Table) | Provides table functions
[List](#List) | A true list
[That](#That) | Provides functions for assert
[ColorConverter](#ColorConverter) | Provides color conversion
[Colors](#Colors) | Provides color constants
... | and more

Tools for the data stage:

module | short description
------|------------
[DataRRaw](#DataRRaw) | Provides tools for the data stage
[EntityData](#EntityData) | 
[ItemData](#ItemData) | 
[RecipeData](#RecipeData) | 

All other modules are internal use only because API not fully tested or work-in-progress. 

### General usage

1. Initialize the global `KuxCoreLib`, which is needed by all modules you include:  
`require("__Kux-CoreLib__/init")`  

2. require a module locally:  
`local ModuleName = require(KuxCoreLib.ModuleName) --[[@as KuxCoreLib.ModuleName]]`  - or -  
```local ModuleName = KuxCoreLib.ModuleName``` -- better way, with documentation support  - or -  
```local ModuleName = require.KuxCoreLib.ModuleName``` -- if you prefer 'require' keyword

alternatively you can require modules globally:
- includa all modules globally:  
`require("__Kux-CoreLib__/lib/@")` all modules except data  
`require("__Kux-CoreLib__/lib/data/@")` all modules include data  
-  include a single module globally:  
`require(KuxCoreLib.<ModuleName>).asGlobal()` - or -  
`KuxCoreLib.<ModuleName>.asGlobal()` - or -  
`require.KuxCoreLib.<ModuleName>.asGlobal()`

`asGLobal()`perfoms some checks before make global,  
alternatively you can use:  
`ModuleName = require(KuxCoreLib.ModuleName) --[[@as KuxCoreLib.ModuleName]]`  - or -  
`ModuleName = KuxCoreLib.ModuleName` - or -  
`ModuleName = require.KuxCoreLib.ModuleName` -- if you prefer 'require' keyword

NOTE: if you use `require("__Kux-CoreLib__/lib/<module>")` you dont need `require("__Kux-CoreLib__/init")`

### Examples

> data.lua
> ```Lua
> require("__Kux-CoreLib__/init")
> require("your own modules")
> local DataRaw = KuxCoreLib.Data.DataRaw
> local EntityData = KuxCoreLib.Data.EntityData
> local ItemData = KuxCoreLib.Data.ItemData
> local RecipeData = KuxCoreLib.Data.RecipeyData
> 
> local entity = EntityData.clone("type","name","newname")
> local item   = ItemData.  clone("name",entity)
> local recipe = EntityData.clone("name",item)
> data:extend{entity, item, recipe}
> ```

> control.lua
> ```Lua
> require("__Kux-CoreLib__/lib/@") -- all modules global
> require("your own modules")
> ```


## Modules

### Lua

- iif
- try/catch/finaly
- switch
- switchp
- safeget
- safeset
- ...and more

all functions are global

### String

Provides string functions

- String.concat - Concatenances a string
- String.format - Formats a string (format="%1 %2 ...")
- String.replace - Replaces parts of a string (format="{name}")
- String.print
- String.startsWith - Gets a value indication the string starts with the specifed value.
- String.endsWith - Gets a value indication the string ends with the specifed value.
- String.split - Splits a string.
- String.escape - Escapes a string
- String.pretty - Returns a string that presents the prettified value
- String.toChars - Return an array with each char from string
- ...

global:  
- str - String.pretty with debug formatting

### Table

Provides table functions

- Table.getValues - Gets all values.
- Table.getKeys - Gets all keys
- Table.indexOf - Gets the first index of the value
- Table.keyOf - Gets the first key which has the value
- ...

### That

Provides functions for use with `assert`

Usage: `assert(That.IsNotNil(value))`

- That.Argument.IsNotNil
- That.Argument.IsNotNilOrEmpty
- That.IsEqual
- That.IsNotEqual
- That.IsReferenceEqual
- That.IsTrue
- That.IsFalse
- That.IsNil
- That.IsNilOrFalse
- That.IsNotNil
- That.IsNotNilOrFalse
- That.IsTypeOf
- That.IsNotTypeOf
- ...

### ColorConverter

- rgbToHsl - RGB to HSL conversion
- hslToRgb - HSL to RGB conversion
- rgbToHsv - RGB to HSV conversion
- hsvToRgb - HSV to RGB conversion

### Colors

Contains A few color constants.

### List

A true list. Act as wrappeer for a table. fixes some bugs from `table` methods.
- save handling of nil entries
- you get always the correct length
- complete enumeration, include `nil`, also with ipairs

Usage:

`local t = get_a_table()`  
`local list = List:new(t)`  
make some changes, all changes will be applied to the table immediately.  
`use_a_table(t)`

### ModInfo

Provides information about the current mod.  
All information are available in any stage.

name          | description
--------------|-------------
name          | The name of the current mod e.g. `"ModName"`
path          | The path of the current mod e.g. `"__ModName__/"`
prefix        | The prefix of the current mod e.g. `"ModName-"`
[current_stage](#current_stage) | The current stage. One of: "settings",..., "data", ..., "control", ,,,

#### current_stage
Gets the current stage, one of:  
- "settings", "settings-updates", "settings-final-fixes",  
- "data", "data-updates", "data-final-fixes",  
- "control", "control-on-init", "control-on-load", "control-on-configuration-changed", "control-on-loaded"

## Development environment

VSCode with some (optional) Extensions:

- [Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) (sumnneko)
- [Factorio Lua API autocomplete](https://marketplace.visualstudio.com/items?itemName=svizzini.factorio-lua-api-autocomplete) (Simon Vizzini)
- [Factorio Modding Tool Kit](https://marketplace.visualstudio.com/items?itemName=justarandomgeek.factoriomod-debug) (justarandomgeek)
- [Lua Debug](https://marketplace.visualstudio.com/items?itemName=actboy168.lua-debug) (actboy168)

To use the autocmnplete feature also for Kux-CoreLib, unzip the mod and adjust the configuration. Example:
> settings.json  
> `"Lua.workspace.library": ["../Kux-CoreLib/lib"]`
