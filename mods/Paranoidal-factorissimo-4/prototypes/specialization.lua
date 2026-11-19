local prefix = "factory-specialization-"
local base = "__base__/graphics/icons/"
local rows = {
    {name = "speed", module = "speed-module"},
    {name = "efficiency", module = "efficiency-module"},
}

local icons = {{icon = "__Paranoidal-factorissimo-4__/graphics/technology/factory-architecture-1.png", icon_size = 256}}
local effects = {}
for i, row in ipairs(rows) do
    local icon = base .. row.module .. ".png"
    icons[#icons + 1] = {icon = icon, icon_size = 64, scale = 0.6, shift = {32 * (2 * i - 3), 39}}
    effects[#effects + 1] = {
        type = "nothing", icon = icon, icon_size = 64, use_icon_overlay_constant = false,
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
    for tier = 1, 3 do
        local suffix = tier == 1 and "" or "-" .. tier
        data:extend {{
            type = "sprite", name = prefix .. row.name .. "-" .. tier,
            filename = base .. row.module .. suffix .. ".png", size = 64, mipmap_count = 4,
        }}
    end
end

data:extend {{
    type = "technology",
    name = prefix .. "optimization",
    icons = icons,
    prerequisites = {"factory-architecture-t1"},
    effects = effects,
    unit = {count = 100, time = 20, ingredients = {{"automation-science-pack", 1}}},
    order = "p-q-a-a[b-specialization]",
}}
