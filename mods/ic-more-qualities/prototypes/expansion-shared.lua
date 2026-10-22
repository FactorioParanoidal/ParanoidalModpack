-- Side-effect free prototype helpers of the quality-control expansion (data stage only).
local names = require("scripts.expansion.names")

local M = {}

M.hidden_flags = {
    "not-on-map", "not-blueprintable", "not-deconstructable", "not-upgradable", "no-copy-paste",
    "not-in-kill-statistics", "not-selectable-in-game", "placeable-off-grid", "hide-alt-info", "not-flammable",
    "not-repairable", "no-automated-item-insertion", "no-automated-item-removal",
}

-- Hidden electric consumer: the workshop's electricity and the extra power of production modes.
function M.hidden_power(name, width, height)
    local util = require("util")
    return {
        type = "electric-energy-interface",
        name = name,
        icon = names.graphics .. "icons/refine-workshop.png",
        icon_size = 64,
        hidden = true,
        hidden_in_factoriopedia = true,
        flags = M.hidden_flags,
        selectable_in_game = false,
        is_military_target = false,
        max_health = 1000,
        collision_box = {{-width / 2 + 0.3, -height / 2 + 0.3}, {width / 2 - 0.3, height / 2 - 0.3}},
        collision_mask = {layers = {}},
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            buffer_capacity = "1kJ",
            render_no_power_icon = false,
            render_no_network_icon = false,
        },
        energy_usage = "0W",
        gui_mode = "none",
        allow_copy_paste = false,
        picture = util.empty_sprite(),
    }
end

-- Width and height in whole tiles of a data-stage or runtime bounding box.
function M.box_tiles(box)
    local lt = box.left_top or box[1]
    local rb = box.right_bottom or box[2]
    local x1, y1 = lt.x or lt[1], lt.y or lt[2]
    local x2, y2 = rb.x or rb[1], rb.y or rb[2]
    return math.max(1, math.ceil(x2 - x1 - 0.01)), math.max(1, math.ceil(y2 - y1 - 0.01))
end

return M
