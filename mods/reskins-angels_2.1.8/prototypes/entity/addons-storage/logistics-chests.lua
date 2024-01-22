-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Set input parameters
local inputs = {
    type = "logistic-container",
    mod = "angels",
    icon_layers = 1,
    make_remnants = false,
    -- make_explosions = false,
}

local logistic_map = {
    ["active-provider"] = {tint = util.color("760fd6")},
    ["buffer"] = {tint = util.color("00bf13")},
    ["passive-provider"] = {tint = util.color("ff0000")},
    ["requester"] = {tint = util.color("227dae")},
    ["storage"] = {tint = util.color("ba7713")},
}

-- Reskin Warehouses
if reskins.angels and reskins.angels.triggers.storage.entities then
    for chest, map in pairs(logistic_map) do
        -- Fetch entity
        local name = "angels-warehouse-"..chest
        local entity = data.raw[inputs.type][name]

        -- Check if entity exists, if not, skip this iteration
        if not entity then goto continue end

        -- Determine what tint we're using
        inputs.tint = map.tint

        inputs.group = "addons-storage"

        -- Setup icon details
        inputs.icon_name = "warehouse"
        inputs.icon_base = "logistic-warehouse-"..chest
        inputs.base_entity_name = "oil-refinery"
        inputs.particles = {["big-tint"] = 5, ["medium"] = 2}

        reskins.lib.setup_standard_entity(name, 0, inputs)

        entity.picture = {
            layers = {
                -- Base
                {
                    filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/logistic-warehouse-"..chest..".png",
                    priority = "extra-high",
                    width = 197,
                    height = 223,
                    shift = util.by_pixel(0, -15),
                    hr_version = {
                        filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/hr-logistic-warehouse-"..chest..".png",
                        priority = "extra-high",
                        width = 391,
                        height = 446,
                        shift = util.by_pixel(-0.5, -15),
                        scale = 0.5,
                    }
                },
                -- Shadow
                {
                    filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/logistic-warehouse-shadow.png",
                    priority = "extra-high",
                    width = 297,
                    height = 140,
                    shift = util.by_pixel(51, 30),
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/hr-logistic-warehouse-shadow.png",
                        priority = "extra-high",
                        width = 592,
                        height = 276,
                        shift = util.by_pixel(52.5, 30.5),
                        draw_as_shadow = true,
                        scale = 0.5,
                    }
                },
                -- Light
                {
                    filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/logistic-warehouse-light.png",
                    priority = "extra-high",
                    width = 7,
                    height = 16,
                    shift = util.by_pixel(72, -104),
                    draw_as_light = true,
                    hr_version = {
                        filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/hr-logistic-warehouse-light.png",
                        priority = "extra-high",
                        width = 9,
                        height = 28,
                        shift = util.by_pixel(71.5, -104),
                        draw_as_light = true,
                        scale = 0.5,
                    }
                },
            }
        }

        -- Fix drawing box
        entity.drawing_box = {{-3, -3.5}, {3, 3}}

        -- Label to skip to next iteration
        ::continue::
    end
end

-- Reskin Silos
if reskins.angels and reskins.angels.triggers.storage.entities then
--     for chest, map in pairs(logistic_map) do
--         -- Fetch entity
--         local name = "angels-warehouse-"..chest
--         local entity = data.raw[inputs.type][name]

--         -- Check if entity exists, if not, skip this iteration
--         if not entity then goto continue end

--         -- Determine what tint we're using
--         inputs.tint = map.tint

--         inputs.icon_name = "warehouse"

--         reskins.lib.setup_standard_entity(name, 0, inputs)

--         entity.picture = {
--             layers = {
--                 -- Base
--                 {
--                     filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/warehouse-"..chest.."-base.png",
--                     priority = "extra-high",
--                     width = 164,
--                     height = 189,
--                     shift = util.by_pixel(0, 0),
--                     hr_version = {
--                         filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/hr-warehouse-"..chest.."-base.png",
--                         priority = "extra-high",
--                         width = 328,
--                         height = 376,
--                         shift = util.by_pixel(0, 0),
--                         scale = 0.5,
--                     }
--                 },
--                 -- Shadow
--                 {
--                     filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/warehouse-"..chest.."-shadow.png",
--                     priority = "extra-high",
--                     width = 164,
--                     height = 189,
--                     shift = util.by_pixel(0, 0),
--                     draw_as_shadow = true,
--                     hr_version = {
--                         filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/hr-warehouse-"..chest.."-shadow.png",
--                         priority = "extra-high",
--                         width = 328,
--                         height = 376,
--                         shift = util.by_pixel(0, 0),
--                         draw_as_shadow = true,
--                         scale = 0.5,
--                     }
--                 },
--                 -- Light
--                 {
--                     filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/warehouse-"..chest.."-light.png",
--                     priority = "extra-high",
--                     width = 164,
--                     height = 189,
--                     shift = util.by_pixel(0, 0),
--                     draw_as_light = true,
--                     hr_version = {
--                         filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/hr-warehouse-"..chest.."-light.png",
--                         priority = "extra-high",
--                         width = 328,
--                         height = 376,
--                         shift = util.by_pixel(0, 0),
--                         draw_as_light = true,
--                         scale = 0.5,
--                     }
--                 },
--             }
--         }

--         -- Label to skip to next iteration
--         ::continue::
--     end
end

-- Reskin Big Chests from Angel's Industries
if reskins.angels and reskins.angels.triggers.industries.entities then
    for chest, map in pairs(logistic_map) do
        -- Fetch entity
        local name = "angels-logistic-chest-"..chest
        local entity = data.raw[inputs.type][name]

        -- Check if entity exists, if not, skip this iteration
        if not entity then goto continue end

        -- Determine what tint we're using
        inputs.tint = map.tint

        inputs.group = "addons-storage"

        -- Setup icon details
        inputs.icon_name = "big-chest"
        inputs.icon_base = "logistic-big-chest-"..chest
        inputs.base_entity_name = "storage-tank"
        inputs.particles = {["big"] = 1}

        reskins.lib.setup_standard_entity(name, 0, inputs)

        entity.picture = {
            layers = {
                -- Base
                {
                    filename = reskins.angels.directory.."/graphics/entity/addons-storage/big-chest/logistic-big-chest-"..chest..".png",
                    priority = "extra-high",
                    width = 68,
                    height = 85,
                    shift = util.by_pixel(0, -10),
                    hr_version = {
                        filename = reskins.angels.directory.."/graphics/entity/addons-storage/big-chest/hr-logistic-big-chest-"..chest..".png",
                        priority = "extra-high",
                        width = 135,
                        height = 169,
                        shift = util.by_pixel(-0.5, -10.5),
                        scale = 0.5,
                    }
                },
                -- Shadow
                {
                    filename = reskins.angels.directory.."/graphics/entity/addons-storage/big-chest/logistic-big-chest-shadow.png",
                    priority = "extra-high",
                    width = 107,
                    height = 50,
                    shift = util.by_pixel(19, 9),
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.angels.directory.."/graphics/entity/addons-storage/big-chest/hr-logistic-big-chest-shadow.png",
                        priority = "extra-high",
                        width = 209,
                        height = 97,
                        shift = util.by_pixel(18.5, 8.5),
                        draw_as_shadow = true,
                        scale = 0.5,
                    }
                },
                -- Light
                {
                    filename = reskins.angels.directory.."/graphics/entity/addons-storage/big-chest/logistic-big-chest-light.png",
                    priority = "extra-high",
                    width = 4,
                    height = 9,
                    shift = util.by_pixel(21, -42),
                    draw_as_light = true,
                    hr_version = {
                        filename = reskins.angels.directory.."/graphics/entity/addons-storage/big-chest/hr-logistic-big-chest-light.png",
                        priority = "extra-high",
                        width = 5,
                        height = 15,
                        shift = util.by_pixel(20.5, -41.5),
                        draw_as_light = true,
                        scale = 0.5,
                    }
                },
            }
        }

        -- Label to skip to next iteration
        ::continue::
    end
end