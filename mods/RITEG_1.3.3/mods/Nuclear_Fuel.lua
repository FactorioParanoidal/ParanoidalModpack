local mod_name = "__RITEG__"
local RTG = "RITEG-breeder"
local used_up_RTG = "used-up-RITEG-1"

local power = 6000 --kW
--local energy = "40GJ" -- 10x 4GJ!

local tint = {r = 0.7, g = 1, b = 0.7, a = 1}
local size = 3
local shift = {x=32/32, y= -10/32}

if data.raw.item["breeder-fuel-cell"] and data.raw.item["used-up-breeder-fuel-cell"] then
    --[[
    local tech = data.raw.technology["plutonium-breeding"]
    local recipe_name = RTG.."-from-".."used-up-breeder-fuel-cell"

    local enabled = true
    if tech then
        enabled = false
        local tech_effects = tech.effects
        table.insert(tech_effects, {recipe = recipe_name, type = "unlock-recipe"})
    end]]

    -- JohnTheCoolingFan was here

    data:extend({
        -- items
        {
            type = "item",
            name = RTG,
            icons = {{icon = mod_name.."/graphics/icons/"..RTG..".png"}},
            icon_size = 32,
            order = "e[electric-energy-interface]-b[electrci-energy-interface]",
            stack_size = 50,
            subgroup = "energy",
            place_result = RTG
        },

        -- entities
        {
            type = "electric-energy-interface",
            name = RTG,
            icon = mod_name.."/graphics/icons/"..RTG..".png",
            icon_size = 32,
            max_health = 600,
            flags = {"placeable-neutral", "player-creation", "not-repairable"},
            minable = {hardness = 0.2, mining_time = 5, results={{used_up_RTG, 10}, {"used-up-breeder-fuel-cell", 10}}},
            corpse = "medium-remnants",
            collision_box = {{-size/2+0.23, -size/2+0.23},{size/2-0.23, size/2-0.23}},
            selection_box = {{-size/2, -size/2}, {size/2, size/2}},
            enable_gui = false,
            energy_production = (10*power)..'kW',
            energy_source = {
                type = "electric",
                buffer_capacity = (power/60).."kJ",
                input_flow_limit = "0kW",
                render_no_power_icon = false,
                usage_priority = "primary-output",
                output_flow_limit = power ..'kW'
            },
            energy_usage = "0kW",
            picture = {
                filename = mod_name.."/graphics/entities/"..RTG..".png",
                width = 167,
                height = 154,
                priority = "extra-high",
                shift = shift,
                hr_version = {
                    filename = mod_name.."/graphics/entities/".."hr-"..RTG..".png",
                    width = 333,
                    height = 307,
                    priority = "extra-high",
                    shift = shift,
                    scale = 0.5
                }
            }

        },

        -- recipes
        {
            type = "recipe",
            name = RTG,
            icons = {
                {icon = mod_name.."/graphics/icons/"..RTG..".png"}
            },
            icon_size = 32,
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"steel-plate", 25},
                {"advanced-circuit", 15},
                {"RITEG-1", 10},
                {"breeder-fuel-cell", 10}
            },
            result = RTG,
        },
        {
            type = "recipe",
            name = RTG.."-from-"..used_up_RTG,
            icons = {
                {icon = mod_name.."/graphics/icons/"..RTG..".png"},
                {icon = mod_name.."/graphics/icons/recycling.png", scale = 0.5, shift = {-8,8}}
            },
            icon_size = 32,
            energy_required = 30,
            enabled = false,
            ingredients = {
                {used_up_RTG, 10},
                {"breeder-fuel-cell", 10}
            },
            result = RTG
        }
    })

    local tech_effects = data.raw.technology["plutonium-breeding"].effects
    table.insert(tech_effects, {recipe = RTG, type = "unlock-recipe"})
    table.insert(tech_effects, {recipe = RTG.."-from-"..used_up_RTG, type = "unlock-recipe"})

end
