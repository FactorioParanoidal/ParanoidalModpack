local rro = Muluna.rro
local all = {}
local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local space_age_item_sounds = require("__space-age__.prototypes.item_sounds")

local space_boiler = table.deepcopy(data.raw["item"]["boiler"])

space_boiler.name = "muluna-advanced-boiler"
space_boiler.place_result = "muluna-advanced-boiler"
space_boiler.icon="__muluna-graphics__/graphics/thermal-plant/thermal-plant-icon.png"
space_boiler.localised_name = {"entity-name.muluna-advanced-boiler"}
space_boiler.order = "b[steam-power]-aa[muluna-advanced-boiler]"
space_boiler.weight = 40 * kg

local vacuum_heating_tower = table.deepcopy(space_boiler)
vacuum_heating_tower.name = "muluna-vacuum-heating-tower"
vacuum_heating_tower.place_result = "muluna-vacuum-heating-tower"
vacuum_heating_tower.subgroup = "environmental-protection"
vacuum_heating_tower.icons = {
            {
                icon = data.raw["item"]["heating-tower"].icon,
                icon_size = 64,
            },
            {
                icon = data.raw["fluid"]["oxygen"].icon,
                icon_size = data.raw["fluid"]["oxygen"].icon_size,
                scale = 0.25,
                shift = {10,-10},
                draw_background = true,
            }
        }
vacuum_heating_tower.localised_name = {"entity-name.muluna-vacuum-heating-tower"}
vacuum_heating_tower.order = "d[muluna-vacuum-heating-tower]"
vacuum_heating_tower.weight = 200 * kg

local crusher_2 = table.deepcopy(data.raw["item"]["crusher"])

crusher_2.name = "muluna-crusher-2"
crusher_2.place_result = "muluna-crusher-2"
crusher_2.icon = "__muluna-graphics__/graphics/icons/crusher-2.png"
crusher_2.localised_name = {"",{"item-name.crusher"}," 2"}
crusher_2.order = "cb[crusher-2]"
crusher_2.weight = crusher_2.weight*2
--local crusher_2=nil
if data.raw["lab"]["biolab"] then
    local cryolab=table.deepcopy(data.raw["item"]["biolab"])

    cryolab.name="cryolab"
    cryolab.place_result= "cryolab"

    cryolab.icons = {
        {
            icon="__muluna-graphics__/graphics/photometric-lab/photometric-lab-icon.png",
            icon_size=64,
            scale=0.25,
            --tint = {r=0.7,g=0.7,b=1}
        },
        
    }
    cryolab.default_import_location = "muluna"
    Muluna:extend{cryolab}
end
    

local space_platform_advanced = table.deepcopy(data.raw["item"]["space-platform-foundation"])
space_platform_advanced.place_as_tile.result = "advanced-space-platform-foundation"
space_platform_advanced.name = "advanced-space-platform-foundation"
space_platform_advanced.weight = space_platform_advanced.weight / 2

local steel_chest = data.raw["item"]["steel-chest"]

local space_chest = table.deepcopy(data.raw["item"]["steel-chest"])

space_chest=Muluna.rro.util_merge{space_chest,
    {
        name="space-chest-muluna",
        place_result="space-chest-muluna",
        -- icons = {
        --     {
        --     icon=steel_chest.icon,
        --     icon_size=steel_chest.icon_size,
        --     tint = {0.7,0.7,0.7},
            
        --     },
            
        -- },
        subgroup = "space-platform",
        order = "ca[space-chest-muluna]",
        default_import_location = "muluna",
    }

}

space_chest.icons = space_chest.icons or {
            {
            icon=steel_chest.icon,
            icon_size=steel_chest.icon_size,
            
            },
            
        }
for _,icon in pairs(space_chest.icons) do
    icon.tint = {0.7,0.7,0.7}
end

local greenhouse = Muluna.rro.util_merge{table.deepcopy(data.raw["item"]["chemical-plant"]),
    {
        name = "muluna-greenhouse",
        icon = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-icon.png",
        icon_size = 64,
        --place_result = "muluna-greenhouse",
        subgroup = "agriculture",
        order = "az-[muluna-greenhouse]",
        default_import_location = "muluna",
    }
    
}

greenhouse.place_result = nil

local greenhouse_wood = Muluna.rro.util_merge{table.deepcopy(data.raw["item"]["chemical-plant"]),
    {
        name = "muluna-greenhouse-wood",
        icons = {
            {
                icon = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-icon.png",
                icon_size = 64,
            },
            {
                icon = data.raw["item"]["wood"].icon,
                icon_size = data.raw["item"]["wood"].icon_size,
                scale = 0.25,
                shift = {10,-10},
                draw_background = true,
            }
        },
        subgroup = "agriculture",
        place_result = "muluna-greenhouse-wood",
        order = "az-[muluna-greenhouse]-a[muluna-greenhouse-wood]",
        default_import_location = "muluna",
        weight = 5000 * kg,
    }
    
}

local low_density_space_platform_foundation = table.deepcopy(data.raw["item"]["space-platform-foundation"])
low_density_space_platform_foundation = Muluna.rro.util_merge{low_density_space_platform_foundation,
{
    name = "low-density-space-platform-foundation",
    icon = "__muluna-graphics__/graphics/icons/low-density-space-platform-foundation.png",
    order = "aa[low-density-space-platform-foundation]",
    weight = low_density_space_platform_foundation.weight / 2,
    default_import_location = "muluna",
}
}
low_density_space_platform_foundation.place_as_tile.result = "low-density-space-platform-foundation"


local recycling_turbine = Muluna.rro.util_merge{table.deepcopy(data.raw["item"]["fusion-generator"]),
    {
        name = "muluna-cycling-steam-turbine",
        place_result = "muluna-cycling-steam-turbine",
        icon = "__muluna-graphics__/graphics/icons/advanced-steam-turbine.png",
        icon_size = 64,
        order = "f[nuclear-energy]-g[muluna-cycling-steam-turbine]",
        default_import_location = "muluna",
    }

}

local buggy = Muluna.rro.util_merge{table.deepcopy(data.raw["item-with-entity-data"]["car"]),
{
    name = "muluna-rocket-buggy",
    place_result = "muluna-rocket-buggy",
}

}
buggy.icons = {
    {
        icon = data.raw["item-with-entity-data"]["car"].icon,
        icon_size = data.raw["item-with-entity-data"]["car"].icon_size
    },
    {
        icon = data.raw["item"]["rocket-turret"].icon,
        icon_size=data.raw["item"]["rocket-turret"].icon_size,
        --scale=0.3,
        shift = {-2,-12},
        scale=0.2,
    },
}
buggy.default_import_location = "muluna"

local telescope = Muluna.rro.merge(table.deepcopy(data.raw["item"]["assembling-machine-3"]),
    {
        name = "muluna-telescope",
        place_result = "muluna-telescope",
        subgroup = "muluna-telescope",
        order = "a[muluna-telescope]",
        icon = mods["space-exploration-graphics"] and "__space-exploration-graphics__/graphics/icons/telescope.png" or data.raw["item"]["radar"].icon,
        icon_size = 64,
        icons = "_nil",
        default_import_location = "muluna",
    }

)
if not mods["space-exploration-graphics"] then -- Paranoidal: the radar icon of the build
    telescope = Muluna.rro.merge(telescope, Muluna.img.radar_icon_fields(data.raw["item"]["radar"]))
end

local data_cable = { --Forked from Moshine optical cable
    type = "item",
    name = "muluna-data-cable",
    icons = {
        {
            icon = "__muluna-graphics__/graphics/icons/optical-fiber.png",
            tint = {238, 139, 0}
        }
    },
    subgroup = "moshine-production-machine",
    order = "ffi",
    inventory_move_sound = item_sounds.metal_small_inventory_move,
    pick_sound = item_sounds.metal_small_inventory_pickup,
    drop_sound = item_sounds.metal_small_inventory_move,
    place_result = "muluna-data-cable",
    stack_size = 100,
    default_import_location = "nauvis",
    weight = 20 * kg,
    random_tint_color = item_tints.iron_rust
  }

if not mods["Moshine"] or true then
    data_cable.subgroup = "muluna-telescope"
    data_cable.order = "b[muluna-data-cable]"

end

local data_pump = table.deepcopy(data)

-- Paranoidal fork: no big rocket silo item.
Muluna:extend{space_boiler,vacuum_heating_tower,crusher_2,space_chest,greenhouse,greenhouse_wood,low_density_space_platform_foundation,recycling_turbine,buggy,telescope,data_cable}