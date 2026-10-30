local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local flow_rate = settings.startup["valves-pump-speed"].value / 60 -- per second -> per tick

--------------------------------------------------------------------------------
-- Looks (startup setting "valves-graphics"); each returns icons and animations for a config entry.

local looks = {}

-- Own animated sprites (the Flow Control style of the original mod).
local CLASSIC = "__valves__/graphics/"
-- Width of the shared opening animation (8 frames in a row) for each direction.
local anim_width = { north = 122, east = 112, south = 92, west = 102 }

function looks.classic(valve)
    local animations = {}
    for direction, width in pairs(anim_width) do
        animations[direction] = { layers = {
            {
                filename = CLASSIC .. valve.type .. "/" .. direction .. ".png",
                width = 128, height = 128, scale = 0.5,
                line_length = 1, frame_count = 1, repeat_count = 8, animation_speed = 1,
            },
            {
                filename = CLASSIC .. "anim/" .. direction .. ".png",
                width = width, height = 128, scale = 0.5,
                line_length = 8, frame_count = 8, animation_speed = 1,
            },
        } }
    end
    return { { icon = CLASSIC .. valve.type .. "/icon.png" } }, animations
end

-- Static Angels valve from Artisanal Reskins (as in Beta 8): a base sprite plus a tinted mask,
-- one 128 px column per direction; layout as in reskins-angels prototypes/entity/petrochem/valve.lua.
local RESKINS = "__reskins-angels__/graphics/"

function looks.reskins(valve)
    local tint = { r = tonumber(valve.tint:sub(1, 2), 16) / 255, g = tonumber(valve.tint:sub(3, 4), 16) / 255,
        b = tonumber(valve.tint:sub(5, 6), 16) / 255 }
    local animations = {}
    for column, direction in ipairs{ "north", "east", "south", "west" } do
        local x = (column - 1) * 128
        animations[direction] = { layers = {
            { filename = RESKINS .. "entity/petrochem/valve/valve-base.png", x = x, width = 128, height = 128, scale = 0.5 },
            { filename = RESKINS .. "entity/petrochem/valve/valve-mask.png", x = x, width = 128, height = 128, scale = 0.5,
                tint = tint },
        } }
    end
    local icons = {
        { icon = RESKINS .. "icons/petrochem/valve/valve-icon-base.png", icon_size = 64 },
        { icon = RESKINS .. "icons/petrochem/valve/valve-icon-mask.png", icon_size = 64, tint = tint },
    }
    return icons, animations
end

local look = looks[settings.startup["valves-graphics"].value]
if look == looks.reskins and not mods["reskins-angels"] then look = looks.classic end

local function description(mode)
    local factoriopedia = { "", { "entity-description." .. mode .. "-valve" } }
    if mode ~= "one-way" then
        table.insert(factoriopedia, { "valves.valve-shortcuts" })
        table.insert(factoriopedia, { "valves.threshold-settings" })
    end
    table.insert(factoriopedia, { "valves.factoriopedia-bad-connections" })
    return factoriopedia, { "", { "entity-description." .. mode .. "-valve" }, " ", { "valves.more-in-factoriopedia" } }
end

local prototypes = {
    { type = "custom-input", name = "valves-threshold-minus", key_sequence = "PAD -", consuming = "none" },
    { type = "custom-input", name = "valves-threshold-plus", key_sequence = "PAD +", consuming = "none" },
}

for _, valve in ipairs(require("config")) do
    local name = valve.name
    local icons, animations = look(valve)
    local factoriopedia_description, localised_description = description(valve.mode)

    table.insert(prototypes, {
        type = "item",
        name = name,
        icons = icons,
        subgroup = "energy-pipe-distribution", -- moved next to the pump in data-updates
        order = "b[pipe]-d[" .. name .. "]",
        inventory_move_sound = item_sounds.fluid_inventory_move,
        pick_sound = item_sounds.fluid_inventory_pickup,
        drop_sound = item_sounds.fluid_inventory_move,
        place_result = name,
        stack_size = 20,
        random_tint_color = item_tints.iron_rust,
    })
    table.insert(prototypes, {
        type = "recipe",
        name = name,
        energy_required = 2,
        ingredients = {}, -- set in data-updates
        results = { { type = "item", name = name, amount = 1 } },
    })
    table.insert(prototypes, {
        type = "valve",
        name = name,
        icons = icons,
        flags = { "placeable-neutral", "player-creation", "hide-alt-info" },
        minable = { mining_time = 0.2, result = name },
        mode = valve.mode,
        threshold = valve.threshold and settings.startup["valves-default-threshold-" .. valve.type].value / 100,
        factoriopedia_description = factoriopedia_description,
        localised_description = localised_description,
        max_health = 180,
        fast_replaceable_group = "pipe",
        corpse = "pump-remnants",
        dying_explosion = "pump-explosion",
        collision_box = { { -0.29, -0.45 }, { 0.29, 0.45 } },
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        icon_draw_specification = { scale = 0.5 },
        working_sound = {
            sound = { filename = "__base__/sound/pump.ogg", volume = 0.3, audible_distance_modifier = 0.5 },
            max_sounds_per_prototype = 2,
        },
        damaged_trigger_effect = hit_effects.entity(),
        resistances = { { type = "fire", percent = 80 }, { type = "impact", percent = 30 } },
        fluid_box = {
            volume = 400,
            pipe_covers = pipecoverspictures(),
            pipe_connections = {
                { direction = defines.direction.south, position = { 0, 0 }, flow_direction = "output" },
                { direction = defines.direction.north, position = { 0, 0 }, flow_direction = "input-output" },
            },
            hide_connection_info = true,
        },
        flow_rate = flow_rate, -- capped in data-final-fixes
        impact_category = "metal",
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        animations = animations,
    })
end

data:extend(prototypes)
