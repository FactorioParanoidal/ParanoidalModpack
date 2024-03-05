local circuit_tech_unlock 
if data.raw["technology"]["circuit-network"] then
    circuit_tech_unlock = "circuit-network"
end
local copper_tech_unlock
if data.raw["technology"]["electronics"] then
    copper_tech_unlock = "electronics"
end

function wire_shortcut(wire_type, tech_unlock)
    return {
        type = "shortcut",
        name = "WireShortcuts-give-" .. wire_type,
        order = "w[wire]-r[" .. wire_type .. "-wire]",
        action = "lua",
        associated_control_input = "WireShortcuts-give-" .. wire_type,
        localised_name = {"shortcut.WireShortcuts-give-" .. wire_type},
        technology_to_unlock = tech_unlock or circuit_tech_unlock,
        icon = {
            filename = "__WireShortcuts__/graphics/icons/" .. wire_type .. "-wire-x32.png",
            priority = "extra-high-no-scale",
            size = 32,
            scale = 1,
            flags = {"icon"}
        },
        disabled_icon = {
            filename = "__WireShortcuts__/graphics/icons/white-wire-x32.png",
            priority = "extra-high-no-scale",
            size = 32,
            scale = 1,
            flags = {"icon"}
        },
        small_icon = {
            filename = "__WireShortcuts__/graphics/icons/" .. wire_type .. "-wire-x24.png",
            priority = "extra-high-no-scale",
            size = 24,
            scale = 1,
            flags = {"icon"}
        },
        disabled_small_icon = {
            filename = "__WireShortcuts__/graphics/icons/white-wire-x24.png",
            priority = "extra-high-no-scale",
            size = 24,
            scale = 1,
            flags = {"icon"}
        }
    }
end

data:extend({
    wire_shortcut("red"),
    wire_shortcut("green"),
    wire_shortcut("copper", copper_tech_unlock),
    {
        type = "shortcut",
        name = "WireShortcuts-give-cutter",
        order = "w[wire]-c[cutter]",
        action = "lua",
        associated_control_input = "WireShortcuts-give-cutter",
        localised_name = {"shortcut.WireShortcuts-give-cutter"},
        technology_to_unlock = circuit_tech_unlock,
        icon = {
            filename = "__WireShortcuts__/graphics/icons/wire-cutter-x32.png",
            priority = "extra-high-no-scale",
            size = 32,
            scale = 1,
            flags = {"gui-icon"}
        },
        disabled_icon = {
            filename = "__WireShortcuts__/graphics/icons/wire-cutter-white-x32.png",
            priority = "extra-high-no-scale",
            size = 32,
            scale = 1,
            flags = {"gui-icon"}
        },
        small_icon = {
            filename = "__WireShortcuts__/graphics/icons/wire-cutter-x24.png",
            priority = "extra-high-no-scale",
            size = 24,
            scale = 1,
            flags = {"gui-icon"}
        },
        disabled_small_icon = {
            filename = "__WireShortcuts__/graphics/icons/wire-cutter-white-x24.png",
            priority = "extra-high-no-scale",
            size = 24,
            scale = 1,
            flags = {"gui-icon"}
        }
    }
})
