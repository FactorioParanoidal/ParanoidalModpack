
local planet_map_gen = require("__space-age__/prototypes/planet/planet-map-gen")


planet_map_gen.secretas = function ()
    local map_gen_setting = table.deepcopy(data.raw.planet.nauvis.map_gen_settings)

    map_gen_setting.property_expression_names = {}

    map_gen_setting.autoplace_controls = {    }

    map_gen_setting.autoplace_settings["tile"] = {
        settings =
        {
            ["secretas-surface"] = {},
        }
    }
    map_gen_setting.autoplace_settings["decorative"] = {
        -- when this was made, dea dia only had one decorative type.
        settings = {
            ["gas-giant-cloud-1"] = {},
            ["gas-giant-cloud-2"] = {},
            ["gas-giant-cloud-3"] = {}
        }
    }
    map_gen_setting.cliff_settings = nil
    map_gen_setting.autoplace_settings["entity"] = {
        -- a limited set of resources that are still useful together.
        -- with imported holmium, it allows for fusion cells to be made.
        settings = {
            ["fluorine-wind"] = {},
            ["ammonia-wind"] = {},
            ["lithium-wind"] = {},
            -- this type is not used by dea dia, will be kept 
            ["high-temperature-wind"] = {}
        }
    }

    return map_gen_setting
end

return planet_map_gen