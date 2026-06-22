
--- Explanation:
--- If you want your valves to also be managed by this Valves mod then you need to add
--- your valves name to the following mod-data prototype. This will allow my mod to
--- manage your valves thresholds, show warnings, etc. Please see the `data.ValvesModValveConfig`
--- for other options you can set for your valve.
--- 
--- Something like
--- ```lua
--- local valves = data.raw["mod-data"]["mod-valves"].data.valves
--- ---@cast valves table<string, data.ValvesModValveConfig>
--- valves["my-custom-valve"] = { name = "my-custom-valve" }
--- ```
--- 
--- Remember to add an dependency to this mod in your `info.json` file, and and
--- your valve prototypes to the `mod-data` during `data.lua`.

---@class data.ValvesModValveConfig
---@field name string name of the entity
---@field ignore_techs boolean? if true the valves mod will not interfere with the tech tree regarding these valve prototypes
---@field threshold_visualization_scale float? to apply to the threshold visualization number, default is 1.0

data:extend{
    {
        type = "mod-data",
        name = "mod-valves",
        data = {
            ---@type table<string, data.ValvesModValveConfig>
            valves = { }
        }
    },
}