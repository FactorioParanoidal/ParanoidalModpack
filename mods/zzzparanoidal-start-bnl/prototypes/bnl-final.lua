-- Final data of the BnL start (before prototypes/wreck-standard.lua, so the invisible mining
-- targets copy the new health):
-- * every wreck of the start crash and the ship: x10 health, containers at least N slots (room
--   for the ammo that cooks off in a fire, scripts/fire.lua); the ship x1.25 (config.ship_health_multiplier);
-- * only the salvaged lab from the starliner takes the flight recorder (no other lab, also when an
--   earlier stage copied the lab inputs; this is the last data-final-fixes of the modset);
-- * characters can hand-craft "recycling-or-hand-crafting" recipes (scrap recycling).
local config = require("bnl-config")
local shipwreck = require("shipwreck-config")

local names = {[shipwreck.ship] = true}
for name in pairs(shipwreck.wrecks) do names[name] = true end
for kind in pairs({container = true, ["simple-entity"] = true, ["simple-entity-with-owner"] = true}) do
    for name, wreck in pairs(data.raw[kind] or {}) do
        if names[name] then
            wreck.max_health = (wreck.max_health or 10)
                * (name == shipwreck.ship and config.ship_health_multiplier or config.wreck_health_multiplier)
            if kind == "container" and name ~= shipwreck.ship then
                wreck.inventory_size = math.max(wreck.inventory_size or 1, config.wreck_min_slots)
            end
        end
    end
end

local RECORDER, RECORDER_LAB = "bnl-flight-recorder", "salvaged-lab"
for name, lab in pairs(data.raw.lab or {}) do
    local inputs = {}
    for _, input in ipairs(lab.inputs or {}) do
        if input ~= RECORDER then inputs[#inputs + 1] = input end
    end
    if name == RECORDER_LAB then inputs[#inputs + 1] = RECORDER end
    lab.inputs = inputs
end

for _, character in pairs(data.raw.character or {}) do
    local categories = character.crafting_categories or {}
    local present = false
    for _, category in ipairs(categories) do
        if category == "recycling-or-hand-crafting" then present = true end
    end
    if not present then
        categories[#categories + 1] = "recycling-or-hand-crafting"
        character.crafting_categories = categories
    end
end

-- Even Pickier Dollies moves entities of the player's force by teleport: the start wrecks, the
-- starliner, the reactor compartment (a portable atomic bomb), the safe and the other start objects
-- stay where they fell (its mod-data blacklist, read by that mod at runtime).
local dollies = data.raw["mod-data"] and data.raw["mod-data"]["even-pickier-dollies"]
if dollies and dollies.data then
    dollies.data.blacklist_names = dollies.data.blacklist_names or {}
    local list = dollies.data.blacklist_names -- a set: name -> true (scripts/tools.lua of that mod)
    local function add(name) list[name] = true end
    for name in pairs(names) do add(name) end
    for _, spec in ipairs(config.trail.compartments) do add(spec.name) end
    for _, name in ipairs({"bnl-captain-safe", "bnl-escape-pod", "bnl-old-expedition"}) do add(name) end
end
