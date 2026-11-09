--- Discovery rules for the exploration science pack.
---
--- The gate is intentionally item-centric: a science pack is an exploration
--- pack when its canonical recipe is craftable on a single pre-exploration
--- planet. Every technology that unlocks any recipe producing an eligible
--- pack contributes, so alternative recipes are handled without duplicating
--- the pack or letting an alternative recipe change eligibility.
--
-- @module lib.exploration-science.lua
-- @pragma nostrip

local Public = {}

local recipe_results_cache = {}
local recipes_by_item_cache
local recipe_planet_cache = {}
local surface_sets_cache
local planet_discovery_cache
local planet_after_space_cache = {}
local planet_post_exploration_cache = {}
local technology_children_cache
local technology_root_depth_cache
local planet_distance_cache = {}

local GATED_TECHNOLOGY = "muluna-nanofoamed-polymers"
local EXPLORATION_ITEM = "interstellar-science-pack"
local EXPLORATION_TECHNOLOGY = "interstellar-science-pack"
local SPACE_SCIENCE_ITEM = "space-science-pack"
local MOD_DATA_NAME = "muluna-interstellar-science-pack-conditions"

-- These packs are the compatibility baseline. Their items are always eligible
-- even if another mod rewrites the recipe or adds an alternative production
-- path. The canonical technology is also kept as a fallback contributor.
-- Cryogenic, promethium and space science are intentionally absent: Aquilo is
-- gated by the exploration science pack, and the other two are not planetary.
local VANILLA_EXPLORATION_PACKS = {
    ["metallurgic-science-pack"] = {
        planet = "vulcanus",
        technology = "metallurgic-science-pack",
    },
    ["agricultural-science-pack"] = {
        planet = "gleba",
        technology = "agricultural-science-pack",
    },
    ["electromagnetic-science-pack"] = {
        planet = "fulgora",
        technology = "electromagnetic-science-pack",
    },
}

-- These three are always listed first in the gated technology description.
local VANILLA_EXPLORATION_PACK_ORDER = {
    "metallurgic-science-pack",
    "agricultural-science-pack",
    "electromagnetic-science-pack",
}

-- Compatibility bridge for technologies that were manually listed before the
-- dynamic discovery code existed. Technologies that are already contributors
-- to an eligible pack are skipped; the rest become explicit one-technology
-- progress entries. This can be pruned once every entry has been audited.
local LEGACY_PROGRESS_TECHNOLOGIES = {
    "electrochemical-science-pack",
    "cerysian-science-pack",
    "janus-time-science-pack",
    "slp-sunpack",
    "nanite-science-pack",
    "battlefield-science-pack",
    "compression-science-pack",
    "omnia-omnite-processing",
    "igrys-mineral-science",
    "rubia-progression-stage1B",
    "quantum-science-pack",
    "ring-science-pack",
    "anomaly-science-pack",
    "tiberium-mechanical-research",
    "moshine-tech-ai-trainer",
    "pelagos-science-pack",
    "carnal-science-pack",
    "foliax-welcome",
    "arboric-science-pack",
    "planetaris-compression-science",
    "athletic-science-pack",
    "linox-technology_linox-supercomputer",
    "lead-and-gold-tech",
    "s6x-void-science-pack",
    "apicultural-science-pack",
    "vanadium-science-pack",
    "planet-crucible-science-pack",
    "planetaris-bioengineering-science-pack",
    "velora-science-pack",
    "halo-science-pack",
    "abacayba_ominous_science_pack_tech",
    "environment-research-center",
    "s6x-iridescent-science-pack",
    "rabbasca-warpfield-science-pack",
}

if mods["panglia_planet"] then
    table.insert(LEGACY_PROGRESS_TECHNOLOGIES, "cloning-vat-technology")
end

local function get_item(name)
    if data.raw["item"] and data.raw["item"][name] then
        return data.raw["item"][name]
    end
    if data.raw["tool"] and data.raw["tool"][name] then
        return data.raw["tool"][name]
    end
end

local function get_item_icon(item)
    if not item then return nil end
    if item.icon then
        return item.icon, item.icon_size or 64
    end
    if item.icons and item.icons[1] then
        return item.icons[1].icon, item.icons[1].icon_size or 64
    end
end

local function ingredient_name(ingredient)
    if type(ingredient) == "string" then
        return ingredient
    end
    if type(ingredient) == "table" then
        return ingredient.name or ingredient[1]
    end
end

local function is_rigor_generated_recipe(recipe)
    if not recipe then return false end
    if string.find(recipe.name or "", "__rigor_module_mod", 1, true) then
        return true
    end
    for _, category in ipairs(recipe.categories or {}) do
        if string.find(category, "__rigor_module_mod", 1, true) then
            return true
        end
    end
    return false
end

local function is_recycling_recipe(recipe)
    if not recipe then return false end
    if string.sub(recipe.name or "", -#"-recycling") == "-recycling" then
        return true
    end
    for _, category in ipairs(recipe.categories or {}) do
        if category == "recycling" then
            return true
        end
    end
    return false
end

local function get_recipe_item_results(recipe)
    if not recipe then return {} end
    local recipe_name = recipe.name
    if recipe_name and recipe_results_cache[recipe_name] then
        return recipe_results_cache[recipe_name]
    end

    local results = {}
    if recipe.results then
        for _, result in ipairs(recipe.results) do
            if result.name and (result.type == nil or result.type == "item") then
                results[#results + 1] = {
                    name = result.name,
                    amount = result.amount or result.amount_max or result.amount_min or 1,
                    main_product = recipe.main_product == result.name,
                }
            end
        end
    elseif recipe.result then
        results[#results + 1] = {
            name = recipe.result,
            amount = recipe.result_count or 1,
            main_product = true,
        }
    end

    if recipe_name then
        recipe_results_cache[recipe_name] = results
    end
    return results
end

local function get_recipes_by_item()
    if recipes_by_item_cache then
        return recipes_by_item_cache
    end

    recipes_by_item_cache = {}
    for _, recipe in pairs(data.raw["recipe"] or {}) do
        if not is_rigor_generated_recipe(recipe) and not is_recycling_recipe(recipe) then
            for _, result in ipairs(get_recipe_item_results(recipe)) do
                local recipes = recipes_by_item_cache[result.name]
                if not recipes then
                    recipes = {}
                    recipes_by_item_cache[result.name] = recipes
                end
                recipes[#recipes + 1] = recipe
            end
        end
    end
    return recipes_by_item_cache
end

local function get_lab_science_pack_items()
    local items = {}
    for _, lab in pairs(data.raw["lab"] or {}) do
        for _, input in ipairs(lab.inputs or {}) do
            local name = ingredient_name(input)
            if name then
                items[name] = true
            end
        end
    end
    return items
end

local function find_canonical_recipe(item_name)
    local candidates = {}
    for _, recipe in ipairs(get_recipes_by_item()[item_name] or {}) do
        local results = get_recipe_item_results(recipe)
        for _, result in ipairs(results) do
            if result.name == item_name then
                local score = math.min(result.amount or 1, 40)
                if recipe.name == item_name then score = score + 1000 end
                if #results == 1 then score = score + 100 end
                if recipe.main_product == item_name then score = score + 50 end
                candidates[#candidates + 1] = {
                    recipe = recipe,
                    score = score,
                }
            end
        end
    end

    table.sort(candidates, function(a, b)
        if a.score == b.score then
            return a.recipe.name < b.recipe.name
        end
        return a.score > b.score
    end)

    return candidates[1] and candidates[1].recipe or nil
end

local function default_surface_property(property_name)
    local prototype = data.raw["surface-property"] and data.raw["surface-property"][property_name]
    if prototype and prototype.default_value ~= nil then
        return prototype.default_value
    end
    return 0
end

local function matches_surface_conditions(conditions, properties)
    for _, condition in ipairs(conditions or {}) do
        local value = properties and properties[condition.property]
        if value == nil then
            value = default_surface_property(condition.property)
        end
        if condition.min ~= nil and value < condition.min - 1e-9 then
            return false
        end
        if condition.max ~= nil and value > condition.max + 1e-9 then
            return false
        end
    end
    return true
end

local function get_surface_sets()
    if surface_sets_cache then
        return surface_sets_cache
    end

    local planets = {}
    for name, planet in pairs(data.raw["planet"] or {}) do
        planets[#planets + 1] = {
            name = name,
            properties = planet.surface_properties,
        }
    end

    local non_planets = {}
    for name, surface in pairs(data.raw["surface"] or {}) do
        non_planets[#non_planets + 1] = {
            name = name,
            properties = surface.surface_properties,
        }
    end

    surface_sets_cache = {
        planets = planets,
        non_planets = non_planets,
    }
    return surface_sets_cache
end

local function get_single_recipe_planet(recipe)
    local recipe_name = recipe.name
    local cached = recipe_name and recipe_planet_cache[recipe_name]
    if cached then
        return cached.planet, cached.matches_non_planet_surface, cached.count
    end

    local sets = get_surface_sets()
    local count = 0
    local first_planet
    for _, planet in ipairs(sets.planets) do
        if matches_surface_conditions(recipe.surface_conditions, planet.properties) then
            count = count + 1
            if not first_planet then
                first_planet = planet.name
            end
        end
    end

    local matches_non_planet_surface = false
    for _, surface in ipairs(sets.non_planets) do
        if matches_surface_conditions(recipe.surface_conditions, surface.properties) then
            matches_non_planet_surface = true
            break
        end
    end

    local result = {
        planet = count == 1 and first_planet or nil,
        matches_non_planet_surface = matches_non_planet_surface,
        count = count,
    }
    if recipe_name then
        recipe_planet_cache[recipe_name] = result
    end
    return result.planet, result.matches_non_planet_surface, result.count
end

local function technology_depends_on(tech_name, predicate, memo, visiting)
    memo = memo or {}
    visiting = visiting or {}
    if memo[tech_name] ~= nil then
        return memo[tech_name]
    end
    if visiting[tech_name] then
        return false
    end
    visiting[tech_name] = true

    local result = false
    local tech = data.raw["technology"] and data.raw["technology"][tech_name]
    if tech then
        for _, ingredient in ipairs((tech.unit and tech.unit.ingredients) or {}) do
            local name = ingredient_name(ingredient)
            if name and predicate(name) then
                result = true
                break
            end
        end

        if not result then
            for _, prerequisite in ipairs(tech.prerequisites or {}) do
                if predicate(prerequisite) or technology_depends_on(prerequisite, predicate, memo, visiting) then
                    result = true
                    break
                end
            end
        end
    end

    visiting[tech_name] = nil
    memo[tech_name] = result
    return result
end

local function is_space_science(name)
    return name == SPACE_SCIENCE_ITEM
end

local function is_exploration_technology(name)
    if name == EXPLORATION_TECHNOLOGY then
        return true
    end
    local prefix = EXPLORATION_TECHNOLOGY .. "-"
    return string.sub(name, 1, #prefix) == prefix
end

local space_science_cache = {}
local exploration_cache = {}

local function technology_is_after_space_science(tech_name)
    return technology_depends_on(tech_name, is_space_science, space_science_cache)
end

local function technology_is_post_exploration(tech_name)
    if is_exploration_technology(tech_name) then
        return true
    end
    return technology_depends_on(tech_name, is_exploration_technology, exploration_cache)
end

local EMPTY_LIST = {}

local function get_planet_discovery_map()
    if planet_discovery_cache then
        return planet_discovery_cache
    end

    local map = {}
    local function add(planet_name, tech_name)
        local names = map[planet_name]
        if not names then
            names = {}
            map[planet_name] = names
        end
        for _, existing in ipairs(names) do
            if existing == tech_name then
                return
            end
        end
        names[#names + 1] = tech_name
    end

    for tech_name, tech in pairs(data.raw["technology"] or {}) do
        for _, effect in ipairs(tech.effects or {}) do
            if effect.type == "unlock-space-location" and effect.space_location then
                add(effect.space_location, tech_name)
            end
        end
    end

    for planet_name in pairs(data.raw["planet"] or {}) do
        local conventional_name = "planet-discovery-" .. planet_name
        if data.raw["technology"] and data.raw["technology"][conventional_name] then
            add(planet_name, conventional_name)
        end
    end

    planet_discovery_cache = map
    return map
end

local function get_planet_discovery_technologies(planet_name)
    return get_planet_discovery_map()[planet_name] or EMPTY_LIST
end

local function planet_is_after_space_science(planet_name)
    local cached = planet_after_space_cache[planet_name]
    if cached ~= nil then
        return cached
    end

    local result = false
    for _, tech_name in ipairs(get_planet_discovery_technologies(planet_name)) do
        if technology_is_after_space_science(tech_name) then
            result = true
            break
        end
    end
    planet_after_space_cache[planet_name] = result
    return result
end

local function planet_is_post_exploration(planet_name)
    local cached = planet_post_exploration_cache[planet_name]
    if cached ~= nil then
        return cached
    end

    local result = false
    for _, tech_name in ipairs(get_planet_discovery_technologies(planet_name)) do
        if technology_is_post_exploration(tech_name) then
            result = true
            break
        end
    end
    planet_post_exploration_cache[planet_name] = result
    return result
end

local function get_technology_children()
    if technology_children_cache then
        return technology_children_cache
    end

    technology_children_cache = {}
    for tech_name, tech in pairs(data.raw["technology"] or {}) do
        for _, prerequisite in ipairs(tech.prerequisites or {}) do
            local children = technology_children_cache[prerequisite]
            if not children then
                children = {}
                technology_children_cache[prerequisite] = children
            end
            children[#children + 1] = tech_name
        end
    end
    return technology_children_cache
end

local function get_planet_distances(planet_name)
    local cached = planet_distance_cache[planet_name]
    if cached then
        return cached
    end

    local distances = {}
    local discovery_technologies = get_planet_discovery_technologies(planet_name)
    if #discovery_technologies == 0 then
        planet_distance_cache[planet_name] = distances
        return distances
    end

    local children = get_technology_children()
    local queue = {}
    local head = 1
    for _, tech_name in ipairs(discovery_technologies) do
        if data.raw["technology"][tech_name] and distances[tech_name] == nil then
            distances[tech_name] = 0
            queue[#queue + 1] = tech_name
        end
    end

    while head <= #queue do
        local tech_name = queue[head]
        head = head + 1
        local next_distance = distances[tech_name] + 1
        for _, child in ipairs(children[tech_name] or {}) do
            if distances[child] == nil then
                distances[child] = next_distance
                queue[#queue + 1] = child
            end
        end
    end

    planet_distance_cache[planet_name] = distances
    return distances
end

--- Distance of every technology from the closest prerequisite-free technology.
--- Used when a planet's discovery technology cannot reach its pack technologies,
--- as happens on the Any Planet Start starting planet.
local function get_technology_root_depths()
    if technology_root_depth_cache then
        return technology_root_depth_cache
    end

    local children = get_technology_children()
    local depths = {}
    local queue = {}
    local head = 1
    for tech_name, tech in pairs(data.raw["technology"] or {}) do
        local has_prerequisite = false
        for _, prerequisite in ipairs(tech.prerequisites or {}) do
            if data.raw["technology"][prerequisite] then
                has_prerequisite = true
                break
            end
        end
        if not has_prerequisite then
            depths[tech_name] = 0
            queue[#queue + 1] = tech_name
        end
    end

    while head <= #queue do
        local tech_name = queue[head]
        head = head + 1
        local next_depth = depths[tech_name] + 1
        for _, child in ipairs(children[tech_name] or {}) do
            if depths[child] == nil then
                depths[child] = next_depth
                queue[#queue + 1] = child
            end
        end
    end

    technology_root_depth_cache = depths
    return depths
end

local function minimum_technology_distance(technologies, distances)
    local best = math.huge
    for _, tech_name in ipairs(technologies) do
        local distance = distances[tech_name]
        if distance and distance < best then
            best = distance
        end
    end
    return best
end

local function add_technology(group, tech_name)
    group.technology_seen = group.technology_seen or {}
    if not group.technology_seen[tech_name] then
        group.technology_seen[tech_name] = true
        group.technologies[#group.technologies + 1] = tech_name
    end
end

local function collect_eligible_items(lab_items, diagnostics)
    local eligible = {}

    local function reject(item_name, reason, detail)
        diagnostics.rejected_items[#diagnostics.rejected_items + 1] = {
            item = item_name,
            reason = reason,
            detail = detail,
        }
    end

    for item_name, baseline in pairs(VANILLA_EXPLORATION_PACKS) do
        if get_item(item_name) and lab_items[item_name] then
            eligible[item_name] = {
                item = item_name,
                planet = baseline.planet,
                baseline = true,
                fallback_technology = baseline.technology,
            }
        else
            reject(item_name, "baseline item is missing or not accepted by a lab")
        end
    end

    for item_name in pairs(lab_items) do
        if item_name == EXPLORATION_ITEM then
            reject(item_name, "exploration science pack is not a progress source")
        elseif not eligible[item_name] and get_item(item_name) then
            local recipe = find_canonical_recipe(item_name)
            if not recipe then
                reject(item_name, "no canonical recipe")
            else
                local planet, matches_non_planet_surface, planet_count = get_single_recipe_planet(recipe)
                if not planet then
                    local reason
                    if planet_count == 1 and matches_non_planet_surface then
                        reason = "craftable on a space surface"
                    elseif planet_count ~= 1 then
                        reason = "not craftable on exactly one planet"
                    else
                        reason = "no matching planet"
                    end
                    reject(item_name, reason, recipe.name)
                elseif planet_is_post_exploration(planet) then
                    reject(item_name, "canonical planet is unlocked by the exploration science pack", recipe.name)
                else
                    eligible[item_name] = {
                        item = item_name,
                        planet = planet,
                        baseline = false,
                        recipe = recipe.name,
                    }
                end
            end
        end
    end

    return eligible
end

local function collect_groups(eligible, diagnostics)
    local groups = {}
    for item_name, info in pairs(eligible) do
        groups[item_name] = {
            key = item_name,
            item = item_name,
            planet = info.planet,
            baseline = info.baseline,
            technologies = {},
        }
    end

    for tech_name, tech in pairs(data.raw["technology"] or {}) do
        if not technology_is_post_exploration(tech_name) then
            for _, effect in ipairs(tech.effects or {}) do
                if effect.type == "unlock-recipe" then
                    local recipe = data.raw["recipe"] and data.raw["recipe"][effect.recipe]
                    if recipe and not is_rigor_generated_recipe(recipe) and not is_recycling_recipe(recipe) then
                        local recipe_planet = get_single_recipe_planet(recipe)
                        for _, result in ipairs(get_recipe_item_results(recipe)) do
                            local group = groups[result.name]
                            if group and (result.amount or 0) > 0 then
                                local planet = recipe_planet or group.planet
                                local after_space_science = technology_is_after_space_science(tech_name)
                                    or (planet and planet_is_after_space_science(planet))
                                local post_exploration = technology_is_post_exploration(tech_name)
                                    or (planet and planet_is_post_exploration(planet))
                                if after_space_science and not post_exploration then
                                    add_technology(group, tech_name)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Keep the vanilla canonical technology as a contributor even when another
    -- mod has rewritten or removed the technology's unlock-recipe effect.
    for item_name, info in pairs(eligible) do
        if info.baseline and info.fallback_technology and data.raw["technology"][info.fallback_technology] then
            local tech_name = info.fallback_technology
            local group = groups[item_name]
            if group and not technology_is_post_exploration(tech_name) then
                local after_space_science = technology_is_after_space_science(tech_name)
                    or planet_is_after_space_science(group.planet)
                if after_space_science then
                    add_technology(group, tech_name)
                end
            end
        end
    end

    -- Add the old manual list as explicit extras when dynamic detection did
    -- not produce a group for them. This is the compatibility path for packs
    -- whose recipes are not planet-restricted in prototype data, such as
    -- Rabbasca's athletic-science-pack.
    local grouped_technologies = {}
    for _, group in pairs(groups) do
        for _, tech_name in ipairs(group.technologies) do
            grouped_technologies[tech_name] = true
        end
    end

    for _, tech_name in ipairs(LEGACY_PROGRESS_TECHNOLOGIES) do
        if data.raw["technology"][tech_name]
            and not grouped_technologies[tech_name]
            and not technology_is_post_exploration(tech_name)
        then
            groups[tech_name] = {
                key = tech_name,
                item = nil,
                planet = nil,
                legacy = true,
                technologies = { tech_name },
            }
            grouped_technologies[tech_name] = true
            diagnostics.legacy_extras[#diagnostics.legacy_extras + 1] = tech_name
        end
    end

    return groups
end

local function apply_overrides(groups)
    local forced_true = {}
    local forced_false = {}
    for tech_name, tech in pairs(data.raw["technology"] or {}) do
        if tech.muluna_adds_progress_to_exploration_science_pack == true then
            forced_true[tech_name] = true
        elseif tech.muluna_adds_progress_to_exploration_science_pack == false then
            forced_false[tech_name] = true
        end
    end

    for key, group in pairs(groups) do
        for index = #group.technologies, 1, -1 do
            if forced_false[group.technologies[index]] then
                table.remove(group.technologies, index)
            end
        end
        group.technology_seen = nil
        if #group.technologies == 0 then
            groups[key] = nil
        end
    end

    local grouped_technologies = {}
    for _, group in pairs(groups) do
        for _, tech_name in ipairs(group.technologies) do
            grouped_technologies[tech_name] = true
        end
    end

    for tech_name in pairs(forced_true) do
        if data.raw["technology"][tech_name] and not grouped_technologies[tech_name] then
            groups[tech_name] = {
                key = tech_name,
                item = nil,
                planet = nil,
                forced = true,
                technologies = { tech_name },
            }
            grouped_technologies[tech_name] = true
        end
    end

    return groups
end

local function choose_representative(group)
    if group.item then
        local baseline = VANILLA_EXPLORATION_PACKS[group.item]
        if baseline and baseline.technology then
            for _, tech_name in ipairs(group.technologies) do
                if tech_name == baseline.technology then
                    return tech_name
                end
            end
        end
        for _, tech_name in ipairs(group.technologies) do
            if tech_name == group.item then
                return tech_name
            end
        end
    end
    return group.technologies[1]
end

local function keep_first_pack_per_planet(groups)
    local by_planet = {}
    for _, group in pairs(groups) do
        if group.item and group.planet then
            local candidates = by_planet[group.planet]
            if not candidates then
                candidates = {}
                by_planet[group.planet] = candidates
            end
            candidates[#candidates + 1] = group
        end
    end

    for planet_name, candidates in pairs(by_planet) do
        if #candidates > 1 then
            local distances = get_planet_distances(planet_name)
            local group_distances = {}
            local any_reachable = false
            for _, group in ipairs(candidates) do
                local distance = minimum_technology_distance(group.technologies, distances)
                group_distances[group] = distance
                if distance < math.huge then
                    any_reachable = true
                end
            end

            -- Any Planet Start detaches the starting planet's discovery
            -- technology from the prerequisite tree, so nothing is reachable
            -- from it. Fall back to the depth from the tree roots so the
            -- earliest pack on the planet still wins.
            if not any_reachable then
                local root_depths = get_technology_root_depths()
                for _, group in ipairs(candidates) do
                    group_distances[group] = minimum_technology_distance(group.technologies, root_depths)
                end
            end

            local best_group
            local best_distance
            local best_order
            local best_name

            for _, group in ipairs(candidates) do
                local distance = group_distances[group]

                local representative = choose_representative(group)
                local technology = data.raw["technology"][representative]
                local order = technology and technology.order or ""
                local name = representative or group.key

                local better
                if not best_group then
                    better = true
                elseif distance ~= best_distance then
                    better = distance < best_distance
                elseif order ~= best_order then
                    better = order < best_order
                else
                    better = name < best_name
                end

                if better then
                    best_group = group
                    best_distance = distance
                    best_order = order
                    best_name = name
                end
            end

            for _, group in ipairs(candidates) do
                if group ~= best_group then
                    groups[group.key] = nil
                end
            end
        end
    end
end

local function vanilla_pack_priority(group)
    for index, item_name in ipairs(VANILLA_EXPLORATION_PACK_ORDER) do
        if group.item == item_name then
            return index
        end
    end
    return #VANILLA_EXPLORATION_PACK_ORDER + 1
end

local function finalize_groups(groups)
    local packs = {}
    for _, group in pairs(groups) do
        table.sort(group.technologies)
        group.representative = choose_representative(group)
        packs[#packs + 1] = group
    end

    table.sort(packs, function(a, b)
        local a_priority = vanilla_pack_priority(a)
        local b_priority = vanilla_pack_priority(b)
        if a_priority ~= b_priority then
            return a_priority < b_priority
        end
        if a.representative == b.representative then
            return a.key < b.key
        end
        return a.representative < b.representative
    end)
    return packs
end

local function compute_required_science_packs(pack_count)
    if pack_count <= 0 then
        return 0
    end

    if settings.startup["muluna-interstellar-science-pack-dynamic-packs-required"].value == false then
        local configured = settings.startup["muluna-interstellar-science-pack-packs-required"].value
        return math.max(1, math.min(configured, pack_count))
    end

    local percentage = settings.startup["muluna-interstellar-science-pack-dynamic-packs-required-percentage-required"].value / 100
    return math.max(1, math.ceil(pack_count * percentage))
end

--- Discover the exploration science pack groups from the current prototypes.
--- @return table
function Public.detect()
    space_science_cache = {}
    exploration_cache = {}
    recipe_results_cache = {}
    recipes_by_item_cache = nil
    recipe_planet_cache = {}
    surface_sets_cache = nil
    planet_discovery_cache = nil
    planet_after_space_cache = {}
    planet_post_exploration_cache = {}
    technology_children_cache = nil
    technology_root_depth_cache = nil
    planet_distance_cache = {}

    local diagnostics = {
        rejected_items = {},
        legacy_extras = {},
        legacy_technologies = {},
    }
    for _, tech_name in ipairs(LEGACY_PROGRESS_TECHNOLOGIES) do
        diagnostics.legacy_technologies[#diagnostics.legacy_technologies + 1] = tech_name
    end
    local lab_items = get_lab_science_pack_items()
    local eligible = collect_eligible_items(lab_items, diagnostics)
    local groups = collect_groups(eligible, diagnostics)
    groups = apply_overrides(groups)
    keep_first_pack_per_planet(groups)
    local packs = finalize_groups(groups)

    local science_packs = {}
    for _, group in ipairs(packs) do
        science_packs[#science_packs + 1] = group.representative
    end

    table.sort(diagnostics.rejected_items, function(a, b)
        return a.item < b.item
    end)
    table.sort(diagnostics.legacy_extras)

    return {
        packs = packs,
        science_packs = science_packs,
        required_science_packs = compute_required_science_packs(#packs),
        diagnostics = diagnostics,
    }
end

local function is_generated_label(effect, gated_technology)
    return effect.type == "nothing"
        and type(effect.effect_description) == "table"
        and effect.effect_description[1] == "technology-effect.contributes-to-discovery"
        and effect.effect_description[2] == gated_technology
end

local function build_label_effect(conditions)
    local item = get_item(EXPLORATION_ITEM)
    local icon, icon_size = get_item_icon(item)
    if not icon then
        return nil
    end
    return {
        type = "nothing",
        icons = {
            {icon = "__muluna-graphics__/graphics/icons/green-rectangle.png", icon_size = 64},
            {icon = icon, icon_size = icon_size, shift = {0, 0}, scale = 0.375},
            {
                icon = "__core__/graphics/icons/technology/effect-constant/effect-constant-recipe-productivity.png",
                icon_size = 64,
            },
        },
        effect_description = {
            "technology-effect.contributes-to-discovery",
            conditions.gated_technology,
            {"technology-name." .. conditions.gated_technology},
            tostring(conditions.required_science_packs or 0),
        },
    }
end

--- Add the discovery label to every contributor technology and remove labels
--- generated by an earlier call.
--- @param conditions table
function Public.apply_labels(conditions)
    local gated_technology = conditions.gated_technology
    if not gated_technology then
        return
    end

    for _, tech in pairs(data.raw["technology"] or {}) do
        if tech.effects then
            for index = #tech.effects, 1, -1 do
                if is_generated_label(tech.effects[index], gated_technology) then
                    table.remove(tech.effects, index)
                end
            end
        end
    end

    local label = build_label_effect(conditions)
    if not label then
        return
    end

    local labeled = {}
    for _, group in ipairs(conditions.packs or {}) do
        for _, tech_name in ipairs(group.technologies or {}) do
            local tech = data.raw["technology"][tech_name]
            if tech and not labeled[tech_name] then
                labeled[tech_name] = true
                tech.effects = tech.effects or {}
                tech.effects[#tech.effects + 1] = table.deepcopy(label)
            end
        end
    end
end

local function build_trigger_icons(conditions)
    local icons = {}
    local shifts = {{0, -8}, {8, 8}, {-8, 8}}
    local main_icon, main_icon_size

    for _, group in ipairs(conditions.packs or {}) do
        if group.item then
            local item = get_item(group.item)
            local icon, icon_size = get_item_icon(item)
            if icon then
                if not main_icon then
                    main_icon = icon
                    main_icon_size = icon_size
                end
                icons[#icons + 1] = {
                    icon = icon,
                    icon_size = icon_size,
                    scale = 0.35,
                    shift = shifts[#icons + 1],
                }
                if #icons == 3 then
                    break
                end
            end
        end
    end

    if not main_icon then
        local fallback = get_item(EXPLORATION_ITEM)
        main_icon, main_icon_size = get_item_icon(fallback)
    end

    return icons, main_icon, main_icon_size
end

--- Rebuild the gated technology's trigger and description from the current
--- group list. Safe to call repeatedly.
--- @param conditions table
function Public.update_gated_technology(conditions)
    local tech = data.raw["technology"] and data.raw["technology"][conditions.gated_technology]
    if not tech then
        return
    end

    local scripted_triggers = helpers.compare_versions(helpers.game_version, "2.0.69") >= 0
    local icons, main_icon, main_icon_size = build_trigger_icons(conditions)

    if scripted_triggers and main_icon then
        local trigger = {
            type = "scripted",
            trigger_description = {
                "research-trigger.muluna-nanofoamed-polymers",
                tostring(conditions.required_science_packs or 0),
            },
            icon = main_icon,
            icon_size = main_icon_size,
        }
        if #icons > 0 then
            trigger.icons = icons
        end
        tech.research_trigger = trigger
        tech.enabled = true
        tech.visible_when_disabled = false
    else
        tech.unit = {
            count = 1,
            time = 1,
            ingredients = {},
        }
        tech.enabled = false
        tech.visible_when_disabled = true
    end

    tech.localised_description = {
        scripted_triggers and "technology-description.muluna-nanofoamed-polymers-2069"
            or "technology-description.muluna-nanofoamed-polymers",
        tostring(conditions.required_science_packs or 0),
    }
    tech.localised_description = {"", tech.localised_description or {"technology-description." .. tech.name}}

    local index = 0
    for _, pack in ipairs(conditions.science_packs or {}) do
        if index <= 18 then
            table.insert(tech.localised_description, "\n[technology=" .. pack .. "]")
            index = index + 1
        end
    end

    if scripted_triggers then
        tech.research_trigger.trigger_description = tech.localised_description
        tech.localised_description = {"item-description.muluna-microcellular-plastic"}
    end
end

--- Recompute conditions and rebuild the generated labels/descriptions.
--- Other mods may call this from their own data-final-fixes after Muluna's.
--- @return table|nil
function Public.refresh()
    local mod_data = data.raw["mod-data"] and data.raw["mod-data"][MOD_DATA_NAME]
    if not mod_data then
        return nil
    end

    local conditions = mod_data.data
    local result = Public.detect()
    conditions.science_packs = result.science_packs
    conditions.packs = result.packs
    conditions.required_science_packs = result.required_science_packs
    conditions.diagnostics = result.diagnostics
    conditions.gated_technology = conditions.gated_technology or GATED_TECHNOLOGY

    Public.apply_labels(conditions)
    Public.update_gated_technology(conditions)
    return conditions
end

return Public
