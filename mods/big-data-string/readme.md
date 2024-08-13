# Big Data String Library
------------------------------------------------------------------------------------------------
We introduce a simple helper mod to transfer data as string through [data lifecycle](https://lua-api.factorio.com/latest/Data-Lifecycle.html) from data stage into control stage.
This mod generates an [item prototype definition](https://wiki.factorio.com/Prototype/Item) with the data string chunked into `localised_description`.
The maximal possible string length is `10 * 20 ^ (20 + 1) ≈ 2 × 10²⁸`.


# Usage example
------------------------------------------------------------------------------------------------

in data.lua:

    local bigpack = require("__big-data-string__.pack")
    local encode = tostring -- for example
    local function set_my_data(name, data)
        return bigpack(name, encode(data))
    end
    -- use it like this
    data:extend{set_my_data(name, data)}


in control.lua:

    local bigunpack = require("__big-data-string__.unpack")
    local decode = tonumber -- for example
    local function get_my_data(name)
        return decode(bigunpack(name))
    end
    -- use it like this
    if get_my_data(name) == 42 then fun(...) end



# Compatibility
------------------------------------------------------------------------------------------------
We haven't discovered any incompatibilities with other mods to date. Please report on the mod page discussion if any incompatibilities are discovered.

# Notes
------------------------------------------------------------------------------------------------
* initial release for 1.1 game version
