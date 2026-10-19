local params = require("parameters")
storage.infinite_research_units = {}
-- peek: estimate only (no storage changes); formula technologies use their current unit count.
local function tech_cost(tech, peek)
	local sum = 0
	if tech.research_unit_ingredients then
		for _, item in pairs(tech.research_unit_ingredients) do
			local name, amount
			if item.type then
				if item.type == "item" then
					name = item.name
					amount = item.amount
				end
			else
				name = item[1]
				amount = item[2]
			end
			if name then
				sum = sum + amount * (params.science_packet_cost[name] or 1)
			end
		end
	end
	local unit_count = tech.research_unit_count
	if tech.research_unit_count_formula and not peek then
		if tech.name then
			-- no record (research started before the mod was added): count of the current level
			unit_count = storage.infinite_research_units[tech.name] or tech.research_unit_count
			storage.infinite_research_units[tech.name] = nil --erasing unusial record
		end
	end
	sum = sum * (unit_count or 0)
	return sum * 0.00001 * params.linear_factor + params.constant_factor * 0.01 * params.constant_share(tech.name)
end

local ignore_qol = settings.startup["research-evolution-factor-ignore-qol"].value
local ignore_infinite = settings.startup["research-evolution-factor-ignore-inf"].value

-- A count_formula technology with more than params.max_finite_levels levels is treated as infinite
-- (same rule as evolution-label.lua); an infinite max_level is 4294967295 at runtime.
local function infinite_tech(tech)
	if not tech.research_unit_count_formula then
		return false
	end
	local proto = tech.prototype
	return proto.max_level - proto.level + 1 > params.max_finite_levels
end

local function ignored_tech(tech)
	return tech.force.name ~= "player"
		or tech.prototype.hidden
		or (ignore_qol and string.sub(tech.name, 1, 4) == "qol-")
		or (ignore_infinite and infinite_tech(tech))
end

-- Paranoidal: estimate for other mods (paranoidal-tech-tree path panel). Returns the summed
-- exponent of the not yet researched, not ignored technologies; evolution after them is
-- 1 - (1 - current) * exp(-sum). Read-only.
remote.add_interface("research_evolution_factor", {
	path_increment = function(force_name, names)
		local force = game.forces[force_name]
		local sum = 0
		if not force or type(names) ~= "table" then
			return sum
		end
		for _, name in pairs(names) do
			local tech = force.technologies[name]
			if tech and not tech.researched and not ignored_tech(tech) then
				sum = sum + tech_cost(tech, true)
			end
		end
		return sum
	end,
})

script.on_event(defines.events.on_research_finished, function(event, by_script)
	local tech = event.research
	if ignored_tech(tech) then
		return
	end
	local inc = tech_cost(tech)
	if by_script == true then
		return
	end
	for _, force in pairs(game.forces) do
		if force.ai_controllable or force == game.forces.enemy then
			force.set_evolution_factor(1 - (1 - force.get_evolution_factor()) * math.exp(-inc))
		end
	end
end)

script.on_event(defines.events.on_research_started, function(event)
	local tech = event.research
	if ignored_tech(tech) then
		return
	end
	if tech.research_unit_count_formula then --is infinite tech?
		if not tech.name then
			return
		end
		if storage.infinite_research_units == nil then
			storage.infinite_research_units = {}
		end
		storage.infinite_research_units[tech.name] = tech.research_unit_count -- save researched technology units count for later use
	end
end)
