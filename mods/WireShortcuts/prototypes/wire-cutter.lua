local electric_wireable = {"electric-pole", "power-switch"}
local circuit_wireable = {
    "arithmetic-combinator",
    "constant-combinator",
    "decider-combinator",
    "programmable-speaker",
    "power-switch",
    "electric-pole",
    "accumulator",
    "container",
    "inserter",
    "lamp",
    "logistic-container",
    "mining-drill",
    "offshore-pump",
    "pump",
    "rail-chain-signal",
    "rail-signal",
    "roboport",
    "storage-tank",
    "train-stop",
    "transport-belt",
    "wall"
}

local box_red = {255, 24, 24}
local box_green = {71, 255, 73}
local box_yellow = {239, 153, 34}
local box_blue = {57, 156, 251}

function wire_cutter(opts)
    return {
        type = "selection-tool",
        name = "wire-cutter-" .. opts.cutter_type,
        icon = "__WireShortcuts__/graphics/icons/wire-cutter-" .. opts.cutter_type .. ".png",
        icon_size = 64,
        flags = {"only-in-cursor", "hidden", "spawnable", "not-stackable"},
        stack_size = 1,
        stackable = false,
        selection_color = opts.primary_color,
        selection_mode = {"buildable-type", "same-force"},
        alt_selection_color = opts.alt_color,
        alt_selection_mode = {"buildable-type", "same-force"},
        selection_cursor_box_type = "not-allowed", -- 'not allowed' just means 'red box'
        alt_selection_cursor_box_type = "not-allowed",
        entity_type_filters = opts.primary_filter or circuit_wireable,
        alt_entity_type_filters = opts.alt_filter or circuit_wireable
    }
end

data:extend({
    wire_cutter {
        cutter_type = "universal",
        primary_color = box_blue,
        alt_color = box_yellow,
        alt_filter = electric_wireable
    },
    wire_cutter {
        cutter_type = "copper",
        primary_color = box_yellow,
        alt_color = box_blue,
        primary_filter = electric_wireable
    },
    wire_cutter {cutter_type = "red", primary_color = box_red, alt_color = box_green},
    wire_cutter {cutter_type = "green", primary_color = box_green, alt_color = box_red}
})
