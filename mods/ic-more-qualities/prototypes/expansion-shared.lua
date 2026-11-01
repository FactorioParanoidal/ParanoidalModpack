-- Side-effect free prototype helpers of the quality-control expansion (data stage only).
local names = require("scripts.expansion.names")

local M = {}

M.hidden_flags = {
    "not-on-map", "not-blueprintable", "not-deconstructable", "not-upgradable", "no-copy-paste",
    "not-in-kill-statistics", "not-selectable-in-game", "placeable-off-grid", "hide-alt-info", "not-flammable",
    "not-repairable", "no-automated-item-insertion", "no-automated-item-removal",
}

-- Hidden electric consumer: the workshop's electricity.
-- show_icons: the engine draws its "no power" / "no network" icons (the workshop building is a burner with an
-- endless drive and has no electric icons of its own).
function M.hidden_power(name, width, height, show_icons)
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
            render_no_power_icon = show_icons == true,
            render_no_network_icon = show_icons == true,
        },
        energy_usage = "0W",
        gui_mode = "none",
        allow_copy_paste = false,
        picture = util.empty_sprite(),
    }
end

return M
