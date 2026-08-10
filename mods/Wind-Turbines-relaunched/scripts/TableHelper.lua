---
--- Created by xyzzycgn.
---
local handle_settings = require("scripts/handle_settings")

local windTurbine4 = handle_settings.WindTurbine4()

--- adds an optional entry to the base table if windTurbine4 is true
--- @param base any table with base entries for the turbines always present
--- @param wt4_entry any additional entry to be added if windTurbine4 is true
local function addOptionalWT4(base, wt4_entry)
    if  windTurbine4 then
        for k, v in pairs(wt4_entry) do
            base[k] = v
        end
    end

    return base
end

return {
    addOptionalWT4 = addOptionalWT4
}


