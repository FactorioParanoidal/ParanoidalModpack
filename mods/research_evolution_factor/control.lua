-- Research raises the evolution of enemy forces (Factorio 2.0 API).
--
-- Every finished level of a counted technology of the "player" force adds an exponent
--   units * pack_cost * 0.00001 * linear_factor + constant_factor * 0.01 * share
-- units: research units of that level as the game charges them (with the map technology price
-- multiplier); pack_cost: sum of amount * science_packet_cost over the unit ingredients;
-- share: params.constant_share of the technology name.
-- Evolution after an exponent x: 1 - (1 - evolution) * exp(-x), on every surface, for every
-- enemy (AI controllable) force. Research by script/command counts the same as by labs.
--
-- Every level counts once per save: storage.counted[name] is the last counted level. A reversed
-- (unresearched) technology keeps its record, so researching it again adds nothing.
--
-- storage.schema: SCHEMA marks a save with this accounting. A save without it (made with the
-- version that did not count science packs) gets its evolution recalculated once, from the
-- researched technologies only: evolution = 1 - exp(-sum of all counted exponents).
local params = require("parameters")

local SCHEMA = 2
local RESEARCH_FORCE = "player"

local ignore_qol = settings.startup["research-evolution-factor-ignore-qol"].value
local ignore_infinite = settings.startup["research-evolution-factor-ignore-inf"].value

-- A count_formula technology with more than params.max_finite_levels levels is treated as infinite
-- (same rule as evolution-label.lua); an infinite max_level is 4294967295 at runtime.
local function infinite(proto)
	return proto.research_unit_count_formula ~= nil and proto.max_level - proto.level + 1 > params.max_finite_levels
end

local function ignored(tech)
	local proto = tech.prototype
	return proto.hidden
		or (ignore_qol and string.sub(tech.name, 1, 4) == "qol-")
		or (ignore_infinite and infinite(proto))
end

-- 2.0 ResearchIngredient is {name = ..., amount = ...}.
local function pack_cost(tech)
	local sum = 0
	for _, ingredient in pairs(tech.research_unit_ingredients) do
		sum = sum + ingredient.amount * (params.science_packet_cost[ingredient.name] or 1)
	end
	return sum
end

-- Research units of one level as the game charges them.
local function unit_count(tech, level)
	local proto = tech.prototype
	local formula = proto.research_unit_count_formula
	if not formula or (level == tech.level and not tech.researched) then
		-- fixed cost, or the level in progress: the engine value (multiplier included)
		return tech.research_unit_count
	end
	local ok, count = pcall(helpers.evaluate_expression, formula, { L = level, l = level })
	if not ok or type(count) ~= "number" then
		return tech.research_unit_count
	end
	local multiplier = 1
	if not proto.ignore_tech_cost_multiplier then
		multiplier = game.difficulty_settings.technology_price_multiplier
	end
	return math.max(1, math.floor(math.floor(count) * multiplier))
end

-- Evolution exponent of one level.
local function level_exponent(tech, level)
	local exponent = params.constant_factor * 0.01 * params.constant_share(tech.name)
	local cost = pack_cost(tech)
	if cost > 0 then
		exponent = exponent + unit_count(tech, level) * cost * 0.00001 * params.linear_factor
	end
	return exponent
end

-- Highest finished level (prototype level - 1 when none).
local function finished_level(tech)
	local proto = tech.prototype
	if tech.researched and not infinite(proto) then
		return proto.max_level
	end
	return math.max(tech.level, proto.level) - 1
end

-- Last level already counted (storage.counted may be missing in an old save before its migration).
local function counted_level(tech)
	-- prototype levels start at 0 for names like "logistics-0"
	local first = tech.prototype.level
	local counted = storage.counted and storage.counted[tech.name]
	if counted == nil then
		return first - 1
	end
	return math.max(counted, first - 1)
end

-- Exponent of the finished, not yet counted levels; marks them counted.
local function take_new_levels(tech)
	local first = counted_level(tech) + 1
	local last = finished_level(tech)
	local sum = 0
	for level = first, last do
		sum = sum + level_exponent(tech, level)
	end
	if last >= first then
		storage.counted[tech.name] = last
	end
	return sum
end

local function counted_tech(tech)
	return tech.valid and tech.force.name == RESEARCH_FORCE and not ignored(tech)
end

local function enemy_forces()
	local list = {}
	for _, force in pairs(game.forces) do
		if force.ai_controllable or force.name == "enemy" then
			list[#list + 1] = force
		end
	end
	return list
end

-- evolution = 1 - (1 - evolution) * exp(-exponent) on the given surfaces (all when nil).
local function apply(exponent, surfaces)
	if exponent <= 0 then
		return
	end
	local factor = math.exp(-exponent)
	for _, force in pairs(enemy_forces()) do
		for _, surface in pairs(surfaces or game.surfaces) do
			force.set_evolution_factor(1 - (1 - force.get_evolution_factor(surface)) * factor, surface)
		end
	end
end

local function raise(exponent)
	storage.total = storage.total + exponent
	apply(exponent)
end

-- Counts every finished level not counted yet (all technologies of the research force).
local function sweep()
	local force = game.forces[RESEARCH_FORCE]
	local sum = 0
	if force then
		for _, tech in pairs(force.technologies) do
			if counted_tech(tech) then
				sum = sum + take_new_levels(tech)
			end
		end
	end
	return sum
end

-- Old save: evolution from scratch, from the researched technologies only.
local function recalculate()
	storage.counted = {}
	storage.total = 0
	storage.total = sweep()
	local evolution = 1 - math.exp(-storage.total)
	for _, force in pairs(enemy_forces()) do
		for _, surface in pairs(game.surfaces) do
			force.set_evolution_factor(evolution, surface)
		end
	end
	storage.schema = SCHEMA
	storage.infinite_research_units = nil -- record of version 1.1.5 and older
	log(string.format("research_evolution_factor: evolution recalculated from research: %.6f (exponent %.6f)",
		evolution, storage.total))
end

local function migrate_if_needed()
	if storage.schema ~= SCHEMA then
		recalculate()
	end
end

local function on_first_tick()
	script.on_event(defines.events.on_tick, nil)
	migrate_if_needed()
end

script.on_init(function()
	storage.counted = {}
	storage.total = 0
	storage.schema = SCHEMA
	raise(sweep())
end)

script.on_load(function()
	-- An old save whose mods did not change gets no on_configuration_changed: migrate on the first tick.
	if storage.schema ~= SCHEMA then
		script.on_event(defines.events.on_tick, on_first_tick)
	end
end)

script.on_configuration_changed(function()
	if storage.schema ~= SCHEMA then
		recalculate()
	else
		-- technologies researched by migrations or added already researched
		raise(sweep())
	end
end)

script.on_event(defines.events.on_research_finished, function(event)
	migrate_if_needed()
	local tech = event.research
	if counted_tech(tech) then
		raise(take_new_levels(tech))
	end
end)

-- A new surface starts with the evolution gained from research.
script.on_event(defines.events.on_surface_created, function(event)
	migrate_if_needed()
	local surface = game.surfaces[event.surface_index]
	if surface then
		apply(storage.total, { surface })
	end
end)

-- Paranoidal: estimate for other mods (paranoidal-tech-tree path panel). Returns the summed
-- exponent of the listed technologies' levels that would still raise evolution (finite
-- technologies: all remaining levels; infinite ones: the current level). Evolution after them is
-- 1 - (1 - current) * exp(-sum). Read-only.
remote.add_interface("research_evolution_factor", {
	path_increment = function(force_name, names)
		local force = game.forces[force_name]
		local sum = 0
		if not force or force.name ~= RESEARCH_FORCE or type(names) ~= "table" then
			return sum
		end
		for _, name in pairs(names) do
			local tech = force.technologies[name]
			if tech and not tech.researched and not ignored(tech) then
				local proto = tech.prototype
				local first = math.max(tech.level, counted_level(tech) + 1)
				local last = infinite(proto) and first or proto.max_level
				for level = first, last do
					sum = sum + level_exponent(tech, level)
				end
			end
		end
		return sum
	end,
})
