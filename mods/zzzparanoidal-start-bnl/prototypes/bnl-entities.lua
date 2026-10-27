-- Entities of the BnL start: the detached compartments of the debris trail (the reactor is an
-- electric-energy-interface, the others are containers), the captain's safe, the multiplayer
-- escape pod, the ship of the previous expedition and the distress beacon.
-- Compartment graphics are built from the vanilla crash-site spaceship renders
-- (review/start-bnl-graphics/make_graphics.py, outside the mod).
local util = require("util")
local sounds = require("__base__.prototypes.entity.sounds")
local icons = "__zzzparanoidal-start-bnl__/graphics/icons/"
local gfx = "__zzzparanoidal-start-bnl__/graphics/entity/compartments/"

-- {width, height, shift x, shift y} of picture / shadow / ground at scale 0.5 (shift in pixels).
local art = {
    reactor = {picture = {562, 454, 0.0, -17.9}, shadow = {646, 506, 12.0, -14.4}, ground = {658, 542, 2.5, -16.9}},
    medbay = {picture = {528, 338, 0.2, -13.5}, shadow = {612, 348, 10.2, -3.0}, ground = {614, 358, -3.2, -2.0}},
    armory = {picture = {370, 374, 0.2, -15.0}, shadow = {398, 402, 18.8, -19.0}, ground = {438, 458, -1.8, -20.0}},
    hydroponics = {picture = {396, 322, 0.0, -12.6}, shadow = {474, 290, 10.5, 12.4}, ground = {490, 290, 0.0, 19.9}},
    engineering = {picture = {346, 330, 0.2, -13.2}, shadow = {426, 352, 10.2, -6.7}},
    pod = {picture = {200, 152, 0.2, -5.8}, shadow = {212, 128, 34.2, 1.2}},
    safe = {picture = {184, 144, 0.2, -5.5}, shadow = {294, 164, 2.8, -3.5}},
}

local function sprite(key, kind)
    local a = art[key][kind]
    return {
        filename = gfx .. key .. "-" .. kind .. ".png",
        priority = "very-low",
        width = a[1],
        height = a[2],
        shift = util.by_pixel(a[3], a[4]),
        scale = 0.5,
        draw_as_shadow = kind == "shadow" or nil,
    }
end

local function picture(key)
    return {layers = {sprite(key, "picture"), sprite(key, "shadow")}}
end

local function ground(key)
    return art[key].ground and sprite(key, "ground") or nil
end

local function flags()
    return {"placeable-neutral", "player-creation", "not-rotatable", "placeable-off-grid", "not-blueprintable"}
end
local map_color = {r = 0.95, g = 0.6, b = 0.1, a = 1}

local function salvage(list)
    local results = {}
    for _, entry in ipairs(list) do
        results[#results + 1] = {type = "item", name = entry[1], amount_min = entry[2], amount_max = entry[3]}
    end
    return results
end

local function hull()
    return salvage({{"steel-plate", 15, 30}, {"iron-gear-wheel", 10, 25}, {"iron-plate", 30, 60}, {"copper-cable", 20, 40}})
end

local function compartment(key, w, h, extra)
    local entity = {
        type = "container",
        name = "bnl-compartment-" .. key,
        icon = icons .. "compartment-" .. key .. ".png",
        icon_size = 64,
        flags = flags(),
        hidden = true,
        map_color = map_color,
        max_health = 4000,
        alert_when_damaged = false,
        allow_copy_paste = false,
        default_status = "broken",
        open_sound = sounds.metal_large_open,
        close_sound = sounds.metal_large_close,
        resistances = {{type = "fire", percent = 100}, {type = "explosion", percent = 50}},
        inventory_size = 32,
        inventory_type = "normal",
        minable = {mining_time = 12, results = hull()}, -- wreck mining times doubled 2026-10-26
        collision_box = {{-w, -h * 1.1}, {w, h * 0.9}},
        selection_box = {{-w - 0.5, -h * 1.1 - 0.6}, {w + 0.5, h * 0.9 + 0.3}},
        dying_explosion = "big-explosion",
        integration_patch_render_layer = "decals",
        integration_patch = ground(key),
        picture = picture(key),
    }
    for k, v in pairs(extra or {}) do entity[k] = v end
    return entity
end

local entities = {
    compartment("medbay", 3.1, 1.85),
    compartment("armory", 2.0, 1.85),
    compartment("hydroponics", 2.3, 1.7),
    -- Fell into a lake: no water collision, so it can lie on the shore half in the water.
    compartment("engineering", 2.0, 1.7, {
        collision_mask = {layers = {item = true, meltable = true, object = true, player = true, is_object = true, is_lower_object = true}},
    }),
    -- Multiplayer escape pod (scripts/capsules.lua).
    compartment("pod", 1.0, 0.7, {name = "bnl-escape-pod", max_health = 1500, inventory_size = 16,
        minable = {mining_time = 6, results = salvage({{"steel-plate", 4, 8}, {"iron-plate", 10, 20}})}}),
}

-- Captain's safe: opens for the BnL code given as circuit signals (scripts/safe.lua).
local steel_chest = data.raw.container["steel-chest"]
local safe = compartment("safe", 0.9, 0.6, {
    name = "bnl-captain-safe",
    max_health = 2000,
    inventory_size = 16,
    -- a bar: scripts/safe.lua closes the whole chest to inserters until it opens
    inventory_type = "with_bar",
    minable = {mining_time = 6, results = salvage({{"steel-plate", 5, 10}})},
    circuit_connector = steel_chest and table.deepcopy(steel_chest.circuit_connector) or nil,
    circuit_wire_max_distance = steel_chest and steel_chest.circuit_wire_max_distance or 9,
})
safe.default_status = nil
entities[#entities + 1] = safe

-- Reactor compartment: power by script (scripts/reactor.lua), the largest compartment.
entities[#entities + 1] = {
    type = "electric-energy-interface",
    name = "bnl-compartment-reactor",
    icon = icons .. "compartment-reactor.png",
    icon_size = 64,
    flags = flags(),
    hidden = true,
    map_color = map_color,
    max_health = 6000,
    alert_when_damaged = false,
    allow_copy_paste = false,
    resistances = {{type = "fire", percent = 100}, {type = "explosion", percent = 50}},
    minable = {mining_time = 20, results = salvage({
        {"steel-plate", 50, 80}, {"iron-gear-wheel", 30, 50}, {"copper-cable", 60, 100}, {"pipe", 20, 40},
        {"concrete", 40, 80}, {"bnl-antenna-part", 1, 1},
    })},
    collision_box = {{-3.3, -2.6}, {3.3, 2.2}},
    selection_box = {{-3.8, -3.3}, {3.8, 2.6}},
    dying_explosion = "massive-explosion",
    energy_source = {
        type = "electric",
        usage_priority = "primary-output",
        buffer_capacity = "500kJ",
        input_flow_limit = "0W",
        output_flow_limit = "10MW",
        render_no_power_icon = false,
        render_no_network_icon = false,
    },
    energy_production = "0W",
    energy_usage = "0W",
    gui_mode = "none",
    integration_patch_render_layer = "decals",
    integration_patch = ground("reactor"),
    picture = picture("reactor"),
}

-- The ship of the previous expedition: the vanilla ship overgrown and faded.
local ship = data.raw.container["crash-site-spaceship"]
if ship then
    local old = table.deepcopy(ship)
    old.name = "bnl-old-expedition"
    old.icon = icons .. "old-expedition.png"
    old.icon_size = 64
    old.icons = nil
    old.flags = flags()
    old.max_health = 3000
    old.inventory_size = 32
    old.minable = {mining_time = 16, results = salvage({{"steel-plate", 20, 40}, {"iron-plate", 40, 80}, {"pipe", 10, 30}})}
    old.dying_explosion = "big-explosion"
    old.map_color = {r = 0.45, g = 0.55, b = 0.35, a = 1}
    for _, layer in ipairs(old.picture.layers or {}) do
        if not layer.draw_as_shadow then layer.tint = {r = 0.62, g = 0.72, b = 0.5, a = 1} end
    end
    entities[#entities + 1] = old
end

-- Distress beacon: a radar in BnL orange that only transmits.
local radar = data.raw.radar.radar
if radar then
    local beacon = table.deepcopy(radar)
    beacon.name = "bnl-distress-beacon"
    beacon.icon = icons .. "distress-beacon.png"
    beacon.icon_size = 64
    beacon.icons = nil
    beacon.minable = {mining_time = 1, result = "bnl-distress-beacon"}
    beacon.energy_usage = "500kW"
    beacon.max_distance_of_sector_revealed = 1
    beacon.max_distance_of_nearby_sector_revealed = 1
    beacon.next_upgrade = nil
    beacon.fast_replaceable_group = nil
    beacon.placeable_by = nil
    local layers = beacon.pictures and beacon.pictures.layers
    if layers and layers[1] then layers[1].tint = {r = 1, g = 0.7, b = 0.4, a = 1} end
    entities[#entities + 1] = beacon

    -- After the SOS (scripts/distress.lua) the beacon only listens: an ordinary radar in paler
    -- orange that is taken apart back into the beacon item.
    local receiver = table.deepcopy(beacon)
    receiver.name = "bnl-distress-receiver"
    receiver.energy_usage = radar.energy_usage
    receiver.max_distance_of_sector_revealed = radar.max_distance_of_sector_revealed
    receiver.max_distance_of_nearby_sector_revealed = radar.max_distance_of_nearby_sector_revealed
    receiver.placeable_by = {item = "bnl-distress-beacon", count = 1}
    receiver.hidden_in_factoriopedia = true
    local receiver_layers = receiver.pictures and receiver.pictures.layers
    if receiver_layers and receiver_layers[1] then receiver_layers[1].tint = {r = 1, g = 0.85, b = 0.7, a = 1} end
    entities[#entities + 1] = receiver
end

data:extend(entities)
