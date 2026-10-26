-- Scrap of the crashed ship (Fulgora mechanic): a resource placed by script along the crash
-- furrow (scripts/scrap.lua), its item and the recycling recipe, which is also hand-craftable.
-- Prototypes and graphics are taken from Factorio: Space Age (Wube Software); the modpack
-- requires the expansion through the quality mod. No autoplace: RSO and the map generator
-- never place it.
local config = require("bnl-config")
local tile_sounds = require("__base__.prototypes.tile.tile-sounds")
local item_sounds = require("__base__.prototypes.item_sounds")
local icons = "__zzzparanoidal-start-bnl__/graphics/icons/"

local function item_exists(name)
    for kind in pairs(defines.prototypes.item) do
        if data.raw[kind] and data.raw[kind][name] then return true end
    end
    return false
end

local results = {}
for _, entry in ipairs(config.scrap.results) do
    if item_exists(entry[1]) then
        results[#results + 1] = {type = "item", name = entry[1], amount = 1, probability = entry[2],
            show_details_in_recipe_tooltip = false}
    else
        log("zzzparanoidal-start-bnl: scrap result unavailable: " .. entry[1])
    end
end

local pictures = {}
for _, name in ipairs({"scrap", "scrap-1", "scrap-2", "scrap-3", "scrap-4", "scrap-5"}) do
    pictures[#pictures + 1] = {size = 64, filename = icons .. name .. ".png", scale = 0.5, mipmap_count = 4}
end

data:extend({
    {
        type = "resource",
        name = "scrap",
        icon = icons .. "scrap.png",
        flags = {"placeable-neutral"},
        order = "a-b-c",
        tree_removal_probability = 0.8,
        tree_removal_max_distance = 32 * 32,
        minable = {mining_particle = "iron-ore-particle", mining_time = 0.5, result = "scrap"},
        walking_sound = tile_sounds.walking.ore,
        collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        resource_patch_search_radius = 12,
        stage_counts = {1600, 1200, 900, 650, 450, 300, 160, 60},
        stages = {
            sheet = {
                filename = "__zzzparanoidal-start-bnl__/graphics/entity/scrap/scrap.png",
                priority = "extra-high",
                size = 128,
                frame_count = 8,
                variation_count = 8,
                scale = 0.5,
            },
        },
        map_color = {0.9, 0.9, 0.9},
        mining_visualisation_tint = {r = 0.77, g = 0.77, b = 0.9, a = 1},
    },
    {
        type = "item",
        name = "scrap",
        icon = icons .. "scrap.png",
        pictures = pictures,
        subgroup = "bnl-start",
        order = "f[scrap]",
        stack_size = 50,
        auto_recycle = false,
        inventory_move_sound = item_sounds.resource_inventory_move,
        pick_sound = item_sounds.resource_inventory_pickup,
        drop_sound = item_sounds.resource_inventory_move,
    },
    {
        type = "recipe",
        name = "scrap-recycling",
        icons = {
            {icon = icons .. "scrap.png", scale = 0.4},
            {icon = "__quality__/graphics/icons/recycling-top.png"},
        },
        category = "recycling-or-hand-crafting",
        subgroup = "bnl-start",
        order = "g[scrap-recycling]",
        enabled = true,
        auto_recycle = false,
        energy_required = 0.2,
        ingredients = {{type = "item", name = "scrap", amount = 1}},
        results = results,
    },
})
