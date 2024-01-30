-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Set input parameters
local inputs = {
    type = "container",
    mod = "angels",
    tint = util.color("403630"),
    icon_layers = 1,
    make_remnants = false,
    -- make_explosions = false,
}

-- Reskin Warehouses
if reskins.angels and reskins.angels.triggers.storage.entities then
    -- Fetch entity
    local name = "angels-warehouse"
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if entity then
        inputs.group = "addons-storage"
        inputs.icon_name = "warehouse"
        inputs.base_entity_name = "oil-refinery"
        inputs.particles = {["big-tint"] = 5, ["medium"] = 2}

        reskins.lib.setup_standard_entity(name, 0, inputs)

        entity.picture = {
            layers = {
                -- Base
                {
                    filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/warehouse.png",
                    priority = "extra-high",
                    width = 197,
                    height = 223,
                    shift = util.by_pixel(0, -15),
                    hr_version = {
                        filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/hr-warehouse.png",
                        priority = "extra-high",
                        width = 391,
                        height = 446,
                        shift = util.by_pixel(-0.5, -15),
                        scale = 0.5,
                    }
                },
                -- Shadow
                {
                    filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/warehouse-shadow.png",
                    priority = "extra-high",
                    width = 297,
                    height = 140,
                    shift = util.by_pixel(51, 30),
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/hr-warehouse-shadow.png",
                        priority = "extra-high",
                        width = 592,
                        height = 276,
                        shift = util.by_pixel(52.5, 30.5),
                        draw_as_shadow = true,
                        scale = 0.5,
                    }
                },
            }
        }

        -- Fix drawing box
        entity.drawing_box = {{-3, -3.5}, {3, 3}}
    end
end

-- Reskin Silos
if reskins.angels and reskins.angels.triggers.storage.entities then
    -- -- Fetch entity
    -- local name = "angels-warehouse"
    -- local entity = data.raw[inputs.type][name]

    -- -- Check if entity exists, if not, skip this iteration
    -- if entity then
    --     inputs.group = "addons-storage"
    --     inputs.icon_name = "warehouse"

    --     reskins.lib.setup_standard_entity(name, 0, inputs)

    --     entity.picture = {
    --         layers = {
    --             -- Base
    --             {
    --                 filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/warehouse.png",
    --                 priority = "extra-high",
    --                 width = 197,
    --                 height = 223,
    --                 shift = util.by_pixel(0, -15),
    --                 hr_version = {
    --                     filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/hr-warehouse.png",
    --                     priority = "extra-high",
    --                     width = 391,
    --                     height = 446,
    --                     shift = util.by_pixel(-0.5, -15),
    --                     scale = 0.5,
    --                 }
    --             },
    --             -- Shadow
    --             {
    --                 filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/warehouse-shadow.png",
    --                 priority = "extra-high",
    --                 width = 297,
    --                 height = 140,
    --                 shift = util.by_pixel(51, 30),
    --                 draw_as_shadow = true,
    --                 hr_version = {
    --                     filename = reskins.angels.directory.."/graphics/entity/addons-storage/warehouse/hr-warehouse-shadow.png",
    --                     priority = "extra-high",
    --                     width = 592,
    --                     height = 276,
    --                     shift = util.by_pixel(52.5, 30.5),
    --                     draw_as_shadow = true,
    --                     scale = 0.5,
    --                 }
    --             },
    --         }
    --     }

    --     -- Fix drawing box
    --     entity.drawing_box = {{-3, -3.5}, {3, 3}}
    -- end
end

-- Reskin Big Chests
if reskins.angels and reskins.angels.triggers.industries.entities then
    -- Fetch entity
    local name = "angels-big-chest"
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if entity then
        inputs.group = "addons-storage"
        inputs.icon_name = "big-chest"
        inputs.base_entity_name = "storage-tank"
        inputs.particles = {["big"] = 1}

        reskins.lib.setup_standard_entity(name, 0, inputs)

        entity.picture = {
            layers = {
                -- Base
                {
                    filename = reskins.angels.directory.."/graphics/entity/addons-storage/big-chest/big-chest.png",
                    priority = "extra-high",
                    width = 68,
                    height = 85,
                    shift = util.by_pixel(0, -10),
                    hr_version = {
                        filename = reskins.angels.directory.."/graphics/entity/addons-storage/big-chest/hr-big-chest.png",
                        priority = "extra-high",
                        width = 135,
                        height = 169,
                        shift = util.by_pixel(-0.5, -10),
                        scale = 0.5,
                    }
                },
                -- Shadow
                {
                    filename = reskins.angels.directory.."/graphics/entity/addons-storage/big-chest/big-chest-shadow.png",
                    priority = "extra-high",
                    width = 107,
                    height = 50,
                    shift = util.by_pixel(19, 9),
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.angels.directory.."/graphics/entity/addons-storage/big-chest/hr-big-chest-shadow.png",
                        priority = "extra-high",
                        width = 209,
                        height = 97,
                        shift = util.by_pixel(18.5, 8.5),
                        draw_as_shadow = true,
                        scale = 0.5,
                    }
                },
            }
        }
    end
end