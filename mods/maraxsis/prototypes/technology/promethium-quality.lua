local science_pack = "promethium-science-pack"

if mods["Krastorio2-spaced-out"] then
    science_pack = "kr-promethium-research-data"
end

local function build_promethium_quality(i, prerequisites, count, q, energy_required)
    local next = data.raw.quality[q.next]

    data:extend {{
        type = "recipe",
        name = "maraxsis-vitamin-infused-promethium-science-" .. i,
        localised_name = {"recipe-name.maraxsis-vitamin-infused-promethium-science", q.name, q.next},
        energy_required = energy_required,
        enabled = false,
        categories = {"maraxsis-hydro-plant"},
        ingredients = {
            {type = "item", name = science_pack, amount = 1, quality_max = q.name, quality_min = q.name},
            {type = "fluid", name = "maraxsis-omega-3", amount = 10 + i * 5},
            {type = "item", name = "bioflux", amount = 1, quality_max = q.name, quality_min = q.name},
        },
        results = {
            {type = "item", name = science_pack, amount = 1, ignored_by_stats = 1, ignored_by_productivity = 1, quality_min = q.next},
            {type = "fluid", name = "water", amount = 20 + i * 5},
        },
        icons = next.icon and {
            {
                icon = data.raw.item[science_pack].icon,
                icon_size = data.raw.item[science_pack].icon_size
            },
            {
                icon = next.icon,
                icon_size = next.icon_size or 64,
                scale = 0.25,
                shift = {-8, 8},
                floating = true
            },
        } or nil,
        allow_productivity = false,
        can_set_quality = false,
        auto_recycle = false,
        main_product = science_pack,
        surface_conditions = table.deepcopy(data.raw.recipe["promethium-science-pack"].surface_conditions)
    }}

    data:extend {{
        type = "technology",
        name = "maraxsis-promethium-quality-" .. i,
        icons = {
            {
                icon = "__maraxsis__/graphics/technology/omega-3.png",
                icon_size = 256,
            },
            next.icon and {
                icon = next.icon,
                icon_size = next.icon_size or 64,
                scale = 0.5,
                shift = {45, 45},
                floating = true
            } or nil,
        },
        icon_size = 256,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "maraxsis-vitamin-infused-promethium-science-" .. i,
            },
        },
        prerequisites = prerequisites,
        unit = {
            count = count,
            time = 120,
            ingredients = {}, -- ingredients are filled in final-fixes
        },
    }}
end

local seen = {}
local i = 1
local q = data.raw.quality.normal
local count = 50000
local energy_required = 8
local prerequisites = {"promethium-science-pack", "maraxsis-omega_3"}
while true do
    if type(q.next) ~= "string" then
        break
    end

    build_promethium_quality(i, prerequisites, count, q, energy_required)
    prerequisites = {"maraxsis-promethium-quality-" .. i}

    if seen[q.name] then
        break
    end
    seen[q.name] = true

    if seen["legendary"] then
        count = count * 2
    else
        count = count * 10
    end
    energy_required = energy_required * 2

    i = i + 1
    q = data.raw.quality[q.next]
end
