-- Data stage: the "increases evolution by X%" technology effect.
-- Other mods that change technology costs after this mod's data-final-fixes
-- call relabel/relabel_all again, so the label matches the final cost.
local params = require("__research_evolution_factor__/parameters")

local M = {}

M.effect_keys = {
	["research-evolution-factor-effect"] = true,
	["research-evolution-factor-effect-range"] = true,
	["research-evolution-factor-effect-unknown"] = true,
}

local ignore_qol = settings.startup["research-evolution-factor-ignore-qol"].value
local ignore_infinite = settings.startup["research-evolution-factor-ignore-inf"].value

function M.is_evolution_effect(effect)
	return effect.type == "nothing"
		and type(effect.effect_description) == "table"
		and M.effect_keys[effect.effect_description[1]] == true
end

-- Level range of a technology as the engine sees it: the "-<number>" name suffix,
-- max_level defaults to that level; "infinite" -> nil.
local function level_range(tech)
	local level = tonumber(string.match(tech.name, "%-(%d+)$")) or 1
	local max_level = tech.max_level
	if max_level == "infinite" then
		return level, nil
	end
	return level, math.max(tonumber(max_level) or level, level)
end

-- A count_formula technology with more than params.max_finite_levels levels is treated as infinite.
function M.is_infinite(tech)
	if not (tech.unit and tech.unit.count_formula) then
		return false
	end
	local level, max_level = level_range(tech)
	return max_level == nil or max_level - level + 1 > params.max_finite_levels
end

function M.ignored(tech)
	return tech.hidden
		or (ignore_qol and string.sub(tech.name, 1, 4) == "qol-")
		or (ignore_infinite and M.is_infinite(tech))
end

local function pack_cost(ingredients)
	local sum = 0
	for _, item in pairs(ingredients or {}) do
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
	return sum
end

-- Percent for an evolution of 0, same formula as control.lua.
local function percent(count, cost)
	local inc = count * cost * 0.00001 * params.linear_factor + params.constant_factor * 0.01
	return (1 - math.exp(-inc)) * 100
end

local function format(value)
	return string.format("%.3g", value)
end

-- Returns the effect description, or nil when the technology gets no label.
function M.description(tech)
	if M.ignored(tech) then
		return nil
	end
	local unit = tech.unit
	if not unit then
		-- research_trigger: no science packs, only the constant part.
		return { "research-evolution-factor-effect", format(percent(0, 0)) }
	end
	local cost = pack_cost(unit.ingredients)
	if unit.count_formula then
		local level, max_level = level_range(tech)
		if max_level == nil then
			return { "research-evolution-factor-effect-unknown" }
		end
		local low, high
		for l = level, max_level do
			local ok, count = pcall(helpers.evaluate_expression, unit.count_formula, { L = l, l = l })
			if not ok then
				return { "research-evolution-factor-effect-unknown" }
			end
			local value = percent(math.floor(count), cost)
			low = math.min(low or value, value)
			high = math.max(high or value, value)
		end
		if format(low) == format(high) then
			return { "research-evolution-factor-effect", format(low) }
		end
		return { "research-evolution-factor-effect-range", format(low), format(high) }
	end
	if not unit.count then
		return { "research-evolution-factor-effect-unknown" }
	end
	return { "research-evolution-factor-effect", format(percent(unit.count, cost)) }
end

-- Removes old evolution labels and appends a fresh one as the last effect.
-- extra: optional fields copied into the new effect (icon etc.).
function M.relabel(tech, extra)
	local effects = {}
	for _, effect in ipairs(tech.effects or {}) do
		if not M.is_evolution_effect(effect) then
			table.insert(effects, effect)
		end
	end
	local description = M.description(tech)
	if description then
		local effect = { type = "nothing", effect_description = description }
		for key, value in pairs(extra or {}) do
			effect[key] = value
		end
		table.insert(effects, effect)
	end
	if tech.effects or #effects > 0 then
		tech.effects = effects
	end
end

function M.relabel_all(extra)
	for _, tech in pairs(data.raw.technology) do
		M.relabel(tech, extra)
	end
end

return M
