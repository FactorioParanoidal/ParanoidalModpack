-- Quality-control expansion, data stage: workshop, control post, signals, GUI sprites and inputs.
-- Machine statistics, recipes, refinement recipes and unlocks are finished in expansion-final.lua,
-- after Paranoidal has rebalanced assembling machine 1 and every item exists.
local names = require("scripts.expansion.names")
local util = require("util")

local G = names.graphics
local AM1 = "__base__/graphics/entity/assembling-machine-1/"

local function machine_layers(filename, animated)
    local main = {
        filename = filename, priority = "high", width = 214, height = 226,
        shift = util.by_pixel(0, 2), scale = 0.5,
    }
    local shadow = {
        filename = AM1 .. "assembling-machine-1-shadow.png", priority = "high", width = 190, height = 165,
        shift = util.by_pixel(8.5, 5), scale = 0.5, draw_as_shadow = true,
    }
    if animated then
        main.frame_count, main.line_length = 32, 8
        shadow.line_length, shadow.repeat_count = 1, 32
    end
    return {main, shadow}
end

local function connector()
    -- Global of core/lualib, normally already loaded by the base mod.
    if not circuit_connector_definitions then require("circuit-connector-sprites") end
    local definitions = circuit_connector_definitions
    return definitions and definitions["assembling-machine"]
end

local shared = require("prototypes.expansion-shared")
local hidden_flags = shared.hidden_flags
local hidden_power = shared.hidden_power

local function signal(name, background, glyph, glyph_size, order)
    return {
        type = "virtual-signal",
        name = name,
        subgroup = names.signal_subgroup,
        order = order,
        icons = {
            {icon = G .. "icons/signal-background-" .. background .. ".png", icon_size = 64},
            {icon = glyph, icon_size = glyph_size or 64, scale = 0.32},
        },
    }
end

local function command_signal(name, kind, order)
    return {
        type = "virtual-signal", name = name, subgroup = names.signal_subgroup, order = order,
        icon = G .. "icons/signal-command-" .. kind .. ".png", icon_size = 64,
    }
end

local function sprite(name, file)
    -- "icon": shown both in GUI and in the world (arrows, mode badges).
    return {type = "sprite", name = name, filename = G .. file, size = 64, priority = "extra-high-no-scale", flags = {"icon"}}
end

local S = names.signals
local BASE_SIGNAL = "__base__/graphics/icons/signal/"
local REPAIR = "__base__/graphics/icons/repair-pack.png"
local ALERTS = "__core__/graphics/icons/alerts/"

data:extend({
    {type = "fuel-category", name = names.repair_fuel, fuel_value_type = {"description.ic-repair-resource-value"}},
    {
        type = "burner-usage",
        name = names.repair_fuel,
        empty_slot_sprite = {
            filename = G .. "icons/empty-repair-slot.png", priority = "extra-high-no-scale",
            size = 64, flags = {"gui-icon"},
        },
        empty_slot_caption = {"ic-quality.repair-slot"},
        empty_slot_description = {"ic-quality.repair-slot-description"},
        icon = {
            filename = ALERTS .. "not-enough-repair-packs-icon.png", priority = "extra-high-no-scale",
            width = 64, height = 64, flags = {"icon"},
        },
        no_fuel_status = {"ic-quality.status-no-resource"},
        accepted_fuel_key = "description.ic-accepted-repair-resource",
        burned_in_key = "ic-repair-consumed-by",
    },
    {type = "recipe-category", name = names.refine_category},
    {type = "item-subgroup", name = names.subgroup, group = "production", order = "z-ic-quality"},
    {type = "item-subgroup", name = names.signal_subgroup, group = "signals", order = "z-ic-quality"},

    -- Placeable items; subgroup/order are aligned with assembling machine 1 in expansion-final.lua.
    {
        type = "item", name = names.workshop, icon = G .. "icons/refine-workshop.png", icon_size = 64,
        subgroup = names.subgroup, order = "a[ic-refine-workshop]", place_result = names.workshop,
        stack_size = 10,
    },
    {
        type = "item", name = names.post, icon = G .. "icons/control-post.png", icon_size = 64,
        subgroup = names.subgroup, order = "b[ic-control-post]", place_result = names.post,
        stack_size = 10,
    },
    -- Internal "drive": keeps the burner of the workshop running forever, so its fuel slots only
    -- store repair packs. Electricity is drawn by a hidden interface; packs are drained by script.
    {
        type = "item", name = names.drive, hidden = true, hidden_in_factoriopedia = true,
        icons = {
            {icon = G .. "icons/signal-background-workshop.png", icon_size = 64},
            {icon = BASE_SIGNAL .. "signal-lightning.png", icon_size = 64, scale = 0.32},
        },
        fuel_category = names.repair_fuel, fuel_value = "1EJ", stack_size = 1,
        flags = {"not-stackable", "hide-from-fuel-tooltip"},
    },
    {
        type = "recipe", name = names.workshop, enabled = false, energy_required = 5,
        ingredients = {}, results = {{type = "item", name = names.workshop, amount = 1}},
    },
    {
        type = "recipe", name = names.post, enabled = false, energy_required = 5,
        ingredients = {}, results = {{type = "item", name = names.post, amount = 1}},
    },

    -- Refinement workshop: an assembler in yellow hazard stripes. Furnace logic recognises the
    -- inserted item by itself; the burner slots are the repair-pack store.
    {
        type = "furnace",
        name = names.workshop,
        icon = G .. "icons/refine-workshop.png",
        icon_size = 64,
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {mining_time = 0.2, result = names.workshop},
        max_health = 300,
        corpse = "assembling-machine-1-remnants",
        dying_explosion = "assembling-machine-1-explosion",
        icon_draw_specification = {shift = {0, -0.3}},
        alert_icon_shift = util.by_pixel(0, -12),
        resistances = {{type = "fire", percent = 70}},
        collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        crafting_categories = {names.refine_category},
        crafting_speed = 1,
        source_inventory_size = 1,
        result_inventory_size = 2,
        energy_usage = "75kW",
        energy_source = {
            type = "burner",
            burner_usage = names.repair_fuel,
            fuel_categories = {names.repair_fuel},
            fuel_inventory_size = 2,
            effectivity = 1,
            emissions_per_minute = {pollution = 4},
        },
        module_slots = 0,
        allowed_effects = {},
        effect_receiver = {uses_module_effects = false, uses_beacon_effects = false, uses_surface_effects = false},
        show_recipe_icon = true,
        return_ingredients_on_change = true,
        cant_insert_at_source_message_key = "ic-quality.workshop-cant-refine",
        custom_input_slot_tooltip_key = "ic-quality.workshop-input-slot",
        circuit_wire_max_distance = 9,
        circuit_connector = connector(),
        graphics_set = {animation = {layers = machine_layers(G .. "entity/refine-workshop/refine-workshop.png", true)}},
    },
    hidden_power(names.workshop_power, 3, 3),

    -- Control post: orange stripes in the other direction. Arrows of the outputs are drawn by
    -- script and can be rotated without changing the building picture.
    {
        type = "container",
        name = names.post,
        icon = G .. "icons/control-post.png",
        icon_size = 64,
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {mining_time = 0.2, result = names.post},
        max_health = 300,
        corpse = "assembling-machine-1-remnants",
        dying_explosion = "assembling-machine-1-explosion",
        resistances = {{type = "fire", percent = 70}},
        collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        inventory_size = 8,
        inventory_type = "with_bar",
        quality_affects_inventory_size = false,
        picture = {layers = machine_layers(G .. "entity/control-post/control-post.png", false)},
        circuit_wire_max_distance = 9,
        circuit_connector = connector() and connector()[1],
    },

    -- Hidden emitter of the status signals, wired to the workshop/post by script.
    {
        type = "constant-combinator",
        name = names.emitter,
        icon = G .. "icons/signal-background-post.png",
        icon_size = 64,
        hidden = true,
        hidden_in_factoriopedia = true,
        flags = hidden_flags,
        selectable_in_game = false,
        is_military_target = false,
        max_health = 1000,
        collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
        collision_mask = {layers = {}},
        sprites = util.empty_sprite(),
        activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
        circuit_wire_connection_points = {
            {wire = {red = {0, 0}, green = {0, 0}}, shadow = {red = {0, 0}, green = {0, 0}}},
            {wire = {red = {0, 0}, green = {0, 0}}, shadow = {red = {0, 0}, green = {0, 0}}},
            {wire = {red = {0, 0}, green = {0, 0}}, shadow = {red = {0, 0}, green = {0, 0}}},
            {wire = {red = {0, 0}, green = {0, 0}}, shadow = {red = {0, 0}, green = {0, 0}}},
        },
        draw_circuit_wires = false,
        circuit_wire_max_distance = 3,
    },

    signal(S.ws_working, "workshop", BASE_SIGNAL .. "signal-speed.png", 64, "a[workshop]-a"),
    signal(S.ws_progress, "workshop", BASE_SIGNAL .. "signal-percent.png", 64, "a[workshop]-b"),
    signal(S.ws_grade, "workshop", BASE_SIGNAL .. "signal-star.png", 64, "a[workshop]-c"),
    signal(S.ws_resource, "workshop", REPAIR, 64, "a[workshop]-d"),
    signal(S.ws_need, "workshop", BASE_SIGNAL .. "signal-hourglass.png", 64, "a[workshop]-e"),
    signal(S.ws_no_resource, "workshop", ALERTS .. "not-enough-repair-packs-icon.png", 64, "a[workshop]-f"),
    signal(S.ws_no_item, "workshop", BASE_SIGNAL .. "signal-question-mark.png", 64, "a[workshop]-g"),
    signal(S.ws_output_full, "workshop", ALERTS .. "no-storage-space-icon.png", 64, "a[workshop]-h"),
    signal(S.order_active, "post", BASE_SIGNAL .. "signal-unlock.png", 64, "b[order]-a"),
    signal(S.order_required, "post", BASE_SIGNAL .. "signal-number-sign.png", 64, "b[order]-b"),
    signal(S.order_accepted, "post", BASE_SIGNAL .. "signal-checked-green.png", 64, "b[order]-c"),
    signal(S.order_remaining, "post", BASE_SIGNAL .. "signal-hourglass.png", 64, "b[order]-d"),
    signal(S.order_to_refine, "post", REPAIR, 64, "b[order]-e"),
    signal(S.order_done, "post", BASE_SIGNAL .. "signal-white-flag.png", 64, "b[order]-f"),
    signal(S.order_batches, "post", BASE_SIGNAL .. "signal-stack-size.png", 64, "b[order]-g"),
    command_signal(S.cmd_start, "start", "c[command]-a"),
    command_signal(S.cmd_pause, "pause", "c[command]-b"),
    command_signal(S.cmd_stop, "stop", "c[command]-c"),

    sprite("ic-mode-careful", "icons/mode-careful.png"),
    sprite("ic-mode-precise", "icons/mode-precise.png"),
    sprite("ic-post-arrow-good", "icons/post-arrow-good.png"),
    sprite("ic-post-arrow-refine", "icons/post-arrow-refine.png"),
    sprite("ic-post-arrow-other", "icons/post-arrow-other.png"),

    {
        type = "shortcut",
        name = names.panel_shortcut,
        order = "i[ic-quality-panel]",
        action = "lua",
        toggleable = true,
        associated_control_input = names.panel_hotkey,
        icon = G .. "icons/shortcut-quality-panel-32.png",
        icon_size = 32,
        small_icon = G .. "icons/shortcut-quality-panel-24.png",
        small_icon_size = 24,
    },
    {type = "custom-input", name = names.panel_hotkey, key_sequence = "CONTROL + SHIFT + Q", action = "lua"},
    {type = "custom-input", name = names.rotate, key_sequence = "", linked_game_control = "rotate"},
    {type = "custom-input", name = names.reverse_rotate, key_sequence = "", linked_game_control = "reverse-rotate"},
})
