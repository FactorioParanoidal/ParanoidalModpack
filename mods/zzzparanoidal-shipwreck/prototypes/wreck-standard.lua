-- One standard for every wreck and the ship: mining time, loot from shipwreck-config.lua and an
-- invisible simple-entity target that gives the character the pickaxe animation while mining
-- containers and simple-entity-with-owner wrecks (scripts/mining.lua swaps the selection).
local config = require("shipwreck-config")

local wreck_types = {"container", "simple-entity", "simple-entity-with-owner"}

local function find_wreck(name)
    for _, kind in ipairs(wreck_types) do
        local prototype = data.raw[kind] and data.raw[kind][name]
        if prototype then return prototype end
    end
end

local function item_exists(name)
    for kind in pairs(defines.prototypes.item) do
        if data.raw[kind] and data.raw[kind][name] then return true end
    end
    return false
end

local function results(owner, loot)
    local list = {}
    for _, entry in ipairs(loot) do
        local name, low, high = entry[1], entry[2], entry[3] or entry[2]
        if item_exists(name) then
            local product = {type = "item", name = name, probability = entry.p}
            if low == high then
                product.amount = low
            else
                product.amount_min, product.amount_max = low, high
            end
            list[#list + 1] = product
        else
            log("zzzparanoidal-shipwreck: " .. owner .. ": optional mining loot unavailable: " .. name)
        end
    end
    return list
end

local function mining_target(wreck)
    data:extend({{
        type = "simple-entity",
        name = config.target_prefix .. wreck.name,
        localised_name = wreck.localised_name or {"entity-name." .. wreck.name},
        icon = wreck.icon,
        icons = table.deepcopy(wreck.icons),
        icon_size = wreck.icon_size,
        flags = {"placeable-neutral", "placeable-off-grid", "not-on-map",
            "not-blueprintable", "not-deconstructable", "not-in-kill-statistics"},
        hidden_in_factoriopedia = true,
        max_health = wreck.max_health,
        collision_box = table.deepcopy(wreck.collision_box),
        collision_mask = {layers = {}},
        selection_box = table.deepcopy(wreck.selection_box),
        selection_priority = 255,
        minable = {mining_time = config.mining_time},
        picture = {filename = "__core__/graphics/empty.png", width = 1, height = 1},
    }})
end

local function standardize(name, loot)
    local wreck = find_wreck(name)
    if not wreck then
        log("zzzparanoidal-shipwreck: wreck prototype unavailable: " .. name)
        return
    end
    wreck.minable = {mining_time = config.mining_time, results = results(name, loot)}
    if wreck.type ~= "simple-entity" then mining_target(wreck) end
end

local names = {}
for name in pairs(config.wrecks) do names[#names + 1] = name end
table.sort(names)
for _, name in ipairs(names) do standardize(name, config.wrecks[name].loot) end

standardize(config.ship, config.ship_loot)
local ship = data.raw.container[config.ship]
if ship then ship.inventory_size = config.ship_inventory_size end
