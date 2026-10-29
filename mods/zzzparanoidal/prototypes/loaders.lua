-- Items, recipes and research of the six loader tiers. Until 2026-10-29 Bob's Logistics
-- made them through AAI Loaders; that mod and its 1x1 loaders are gone (user decision).
-- Final costs: tweaks/recipe|technology/platforms-logistics-beta8.lua (data-final-fixes).
-- Machines, place results, icons and tooltips: prototypes/electric-loaders.lua.
-- Technology IDs keep the former aai-* names so research progress in saves survives.
local defs = require("loader-definitions")
if not defs.enabled(mods) then return end
local item_sounds = require("__base__.prototypes.item_sounds")

local tiers = {
    { name = "bob-basic-loader", belt = "bob-basic-transport-belt", tech = "aai-basic-loader", order = "a04",
      category = "crafting", subgroup = "bob-logistic-tier-0" },
    { name = "loader", belt = "transport-belt", tech = "aai-loader", order = "a01",
      category = "crafting", subgroup = "bob-logistic-tier-1" },
    { name = "fast-loader", belt = "fast-transport-belt", tech = "aai-fast-loader", order = "a02",
      category = "crafting", subgroup = "bob-logistic-tier-2" },
    { name = "express-loader", belt = "express-transport-belt", tech = "aai-express-loader", order = "a03",
      category = "crafting-with-fluid", subgroup = "bob-logistic-tier-3" },
    { name = "bob-turbo-loader", belt = "turbo-transport-belt", tech = "aai-turbo-loader", order = "a05",
      category = "crafting-with-fluid", subgroup = "bob-logistic-tier-4" },
    { name = "bob-ultimate-loader", belt = "bob-ultimate-transport-belt", tech = "aai-ultimate-loader", order = "a06",
      category = "crafting-with-fluid", subgroup = "bob-logistic-tier-5" },
}
local icons = { { icon = "__zzzparanoidal__/graphics/loaders/icons/loader-icon-base.png", icon_size = 64 } }

-- 100 = ReStack belt size (tweaks/custom/restack-port.lua). ReStack finds loaders by their
-- entity, but the machines appear only later in electric-loaders.lua.
for _, tier in ipairs(tiers) do
    local order = "d[loader]-" .. tier.order .. "[" .. tier.tech .. "]"
    local belt_item = data.raw.item[tier.belt]
    data:extend({
        {
            type = "item", name = tier.name, icons = table.deepcopy(icons),
            stack_size = 100, weight = 20000, subgroup = tier.subgroup, order = order,
            pick_sound = item_sounds.mechanical_inventory_pickup,
            drop_sound = item_sounds.mechanical_inventory_move,
            inventory_move_sound = item_sounds.mechanical_inventory_move,
            color_hint = belt_item and table.deepcopy(belt_item.color_hint) or nil,
        },
        {
            -- Ingredients and time are set by platforms-logistics-beta8.lua.
            type = "recipe", name = tier.name, category = tier.category, enabled = false,
            energy_required = 1, ingredients = {}, order = order,
            results = { { type = "item", name = tier.name, amount = 1 } },
        },
        {
            -- Prerequisites and cost are set by platforms-logistics-beta8.lua.
            type = "technology", name = tier.tech, order = order, upgrade = false,
            icons = { { icon = "__zzzparanoidal__/graphics/technology/approved-icons/" .. tier.tech .. ".png", icon_size = 256 } },
            effects = { { type = "unlock-recipe", recipe = tier.name } },
            prerequisites = {},
            unit = { count = 1, time = 60, ingredients = { { "automation-science-pack", 1 } } },
        },
    })
end
