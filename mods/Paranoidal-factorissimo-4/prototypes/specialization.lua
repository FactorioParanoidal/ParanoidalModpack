local prefix = "factory-specialization-"
local base = "__base__/graphics/icons/"
local rows = {
    {name = "speed", module = "speed-module"},
    {name = "efficiency", module = "efficiency-module"},
}

local icons = {{icon = "__Paranoidal-factorissimo-4__/graphics/technology/factory-architecture-1.png", icon_size = 256}}
local effects = {}
-- Stored bonus energy only: no autonomous production and no charging from the network.
data:extend {{
    type = "electric-energy-interface", name = prefix .. "power-energy",
    icon = base .. "steam-engine.png", icon_size = 64,
    hidden = true, hidden_in_factoriopedia = true, selectable_in_game = false,
    flags = {"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "hide-alt-info"},
    collision_mask = {layers = {}}, collision_box = {{0, 0}, {0, 0}},
    energy_source = {type = "electric", usage_priority = "primary-output", input_flow_limit = "0W",
        output_flow_limit = "1TW", buffer_capacity = "1J", drain = "0W",
        render_no_power_icon = false, render_no_network_icon = false},
    energy_production = "0W", energy_usage = "0W",
    picture = {filename = "__core__/graphics/empty.png", size = 1},
}, {
    type = "simple-entity-with-owner", name = prefix .. "power",
    icon = base .. "steam-engine.png", icon_size = 64,
    hidden = true, hidden_in_factoriopedia = true,
    flags = {"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "hide-alt-info"},
    collision_mask = {layers = {}}, selection_box = {{-13, -1}, {13, 1}}, selection_priority = 1,
    is_military_target = false, picture = {filename = "__core__/graphics/empty.png", size = 1},
    localised_name = {"factory-specialization.station-name"},
}}
for i, row in ipairs(rows) do
    local icon = base .. row.module .. ".png"
    local research_icon = "__Paranoidal-factorissimo-4__/graphics/icon/" .. row.module .. "-0.png"
    icons[#icons + 1] = {icon = research_icon, icon_size = 64, scale = 0.6, shift = {32 * (2 * i - 3), 39}}
    effects[#effects + 1] = {
        type = "nothing", icon = research_icon, icon_size = 64, use_icon_overlay_constant = false,
        effect_description = {"factory-specialization.unlock-" .. row.name},
    }
    data:extend {{
        type = "simple-entity-with-owner",
        name = prefix .. row.name,
        icon = icon, icon_size = 64,
        hidden = true, hidden_in_factoriopedia = true,
        flags = {"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "hide-alt-info"},
        collision_mask = {layers = {}},
        selection_box = {{-9, -1}, {9, 1}},
        selection_priority = 1,
        is_military_target = false,
        picture = {filename = "__core__/graphics/empty.png", size = 1},
    }}
    data:extend {{
        type = "sprite", name = prefix .. row.name .. "-0",
        filename = "__Paranoidal-factorissimo-4__/graphics/icon/" .. row.module .. "-0.png", size = 64, mipmap_count = 4,
    }}
    for tier = 1, 3 do
        local suffix = tier == 1 and "" or "-" .. tier
        data:extend {{
            type = "sprite", name = prefix .. row.name .. "-" .. tier,
            filename = base .. row.module .. suffix .. ".png", size = 64, mipmap_count = 4,
        }}
    end
end

data:extend {{
    type = "custom-input",
    name = prefix .. "inspect",
    key_sequence = "",
    linked_game_control = "open-gui",
    consuming = "none",
}, {
    type = "technology",
    name = prefix .. "optimization",
    icons = icons,
    prerequisites = {"factory-architecture-t1"},
    effects = effects,
    unit = {count = 100, time = 20, ingredients = {{"automation-science-pack", 1}}},
    order = "p-q-a-a[b-specialization]",
}}
