-- Defect qualities and quality-control research. Runtime handling lives in control.lua.
local M = {}
local model = require("scripts.defects.model")

-- User decision: defects stay at internal level 0, standard is NOT shifted.
-- Level-scaled engine bonuses (fuel, beacon effectivity, default bonuses) are
-- therefore identical to standard; only the explicit fields below penalize.
function M.defect(tier)
    local multiplier = model.multiplier(-tier)
    local shade = .08 + (5 - tier) * .055
    return {
        type = "quality",
        name = "ic-defect-" .. tier,
        localised_name = {"quality-name.ic-defect-" .. tier},
        localised_description = {"quality-description.ic-defect"},
        level = 0,
        -- Sorted before standard ("a"): -5, -4, ... -1.
        order = "0-ic-defect-" .. (5 - tier),
        subgroup = "qualities",
        color = {r = shade, g = shade, b = shade},
        icons = {{
            icon = "__ic-more-qualities__/graphics/icons/quality-uncommon-t" .. tier .. ".png",
            icon_size = 64,
            tint = {r = 0, g = 0, b = 0, a = 1},
        }},
        next = tier > 1 and ("ic-defect-" .. (tier - 1)) or "normal",
        next_probability = .1,
        default_multiplier = multiplier,
        accumulator_capacity_multiplier = multiplier,
        crafting_machine_speed_multiplier = multiplier,
        fluid_wagon_capacity_multiplier = multiplier,
        flying_robot_max_energy_multiplier = multiplier,
        inserter_speed_multiplier = multiplier,
        inventory_size_multiplier = multiplier,
        lab_research_speed_multiplier = multiplier,
        logistic_cell_charging_energy_multiplier = multiplier,
        tool_durability_multiplier = multiplier,
        -- Penalty, not a bonus: more energy and therefore more pollution.
        crafting_machine_energy_usage_multiplier = 1 / multiplier,
        beacon_power_usage_multiplier = 1,
        mining_drill_resource_drain_multiplier = 1,
        science_pack_drain_multiplier = 1,
        range_multiplier = 1,
        asteroid_collector_collection_radius_bonus = 0,
        beacon_supply_area_distance_bonus = 0,
        -- Pole bonuses are assigned by defects-final.lua together with base radii.
        electric_pole_supply_area_distance_bonus = 0,
        electric_pole_wire_reach_bonus = 0,
        equipment_grid_height_bonus = 0,
        equipment_grid_width_bonus = 0,
        logistic_cell_charging_station_count_bonus = 0,
        mining_drill_mining_radius_bonus = 0,
        beacon_module_slots_bonus = 0,
        crafting_machine_module_slots_bonus = 0,
        mining_drill_module_slots_bonus = 0,
        lab_module_slots_bonus = 0,
    }
end

function M.prepare(raw)
    assert(raw.quality and raw.quality.normal, "Missing standard quality")
    assert(raw.technology, "Missing technologies")
    local quality_module = assert(raw.technology["quality-module"], "Missing first quality-module technology")
    assert(raw.quality.normal.level == 0, "Defects require standard quality at level 0")
    for tier = 1, 5 do
        assert(not raw.quality["ic-defect-" .. tier], "Defect quality already registered")
    end
    for level = 1, 10 do
        assert(not raw.technology[model.research(level).name], "Defect research already registered")
    end

    local prototypes = {}
    for tier = 5, 1, -1 do prototypes[#prototypes + 1] = M.defect(tier) end

    for level = 1, 10 do
        local research = model.research(level)
        local prerequisites = research.prerequisite and {research.prerequisite} or {}
        prototypes[#prototypes + 1] = {
            type = "technology",
            name = research.name,
            localised_name = {"technology-name.ic-defect-control", tostring(level)},
            localised_description = {"technology-description.ic-defect-control-preview"},
            icon = "__quality__/graphics/technology/quality-module-1.png",
            icon_size = 256,
            order = "ic-defect-control-" .. string.format("%02d", level),
            prerequisites = prerequisites,
            unit = {count = research.count, time = research.time, ingredients = {{research.science, 1}}},
            -- Runtime reads this force's completed chain.
            enabled = true,
            visible_when_disabled = true,
            effects = {{type = "nothing", effect_description = {"technology-description.ic-defect-control-preview"}}},
        }
    end
    -- Quality modules follow defect control, not the other way around. Preserve
    -- the upstream module prerequisites and all existing researched states.
    local final_control = model.research_prefix .. model.maximum_research
    local prerequisites, present = {}, false
    for _, name in ipairs(quality_module.prerequisites or {}) do
        prerequisites[#prerequisites + 1] = name
        if name == final_control then present = true end
    end
    if not present then prerequisites[#prerequisites + 1] = final_control end
    quality_module.prerequisites = prerequisites
    return prototypes
end

return M
