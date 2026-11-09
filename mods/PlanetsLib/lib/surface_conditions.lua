local util = require("util")
local rro = require("lib.objects")
local Public = {}

-- Restricts the surface conditions of an existing recipe or entity. If the new condition is more restrictive in any way than the existing conditions, those restrictions will be applied.
function Public.restrict_surface_conditions(recipe_or_entity, condition)
	condition = util.table.deepcopy(condition)
	
	local surface_conditions = recipe_or_entity.surface_conditions
			and util.table.deepcopy(recipe_or_entity.surface_conditions)
		or {}
	
	-- If surface condition doesn't already exist, simply insert the condition into the recipe/entity and complete execution
	-- if not (rro.contains(surface_conditions,{property = condition.property, min = "_any", max = "_any"})) then
	-- 	rro.soft_insert(surface_conditions,condition)
	-- 	goto continue
	-- end
	for i = 1, #surface_conditions do
		local existing = surface_conditions[i]
		if existing.property == condition.property then
			if condition.min ~= nil then
				if existing.min ~= nil then
					existing.min = math.max(existing.min, condition.min)
				else
					existing.min = condition.min
				end
			end

			if condition.max ~= nil then
				if existing.max ~= nil then
					existing.max = math.min(existing.max, condition.max)
				else
					existing.max = condition.max
				end
			end
			goto continue
		end
	end

	-- No existing condition found, add new one
	table.insert(surface_conditions, {
		property = condition.property,
		min = condition.min,
		max = condition.max,
	})
	::continue::

	recipe_or_entity.surface_conditions = surface_conditions
end

-- Relaxes the surface conditions of an existing recipe or entity. If a condition with a 'min' field is passed, any existing min conditions on the same property will be relaxed to that min value. Similarly for 'max'. Note that failing to pass a max does not mean that any existing maxima for that property will be removed.
function Public.relax_surface_conditions(recipe_or_entity, condition)
	condition = util.table.deepcopy(condition)

	local surface_conditions = recipe_or_entity.surface_conditions
			and util.table.deepcopy(recipe_or_entity.surface_conditions)
		or {}

	for i = 1, #surface_conditions do
		local existing_condition = surface_conditions[i]
		if existing_condition.property == condition.property then
			if condition.min ~= nil and existing_condition.min ~= nil then
				existing_condition.min = math.min(existing_condition.min, condition.min)
			end

			if condition.max ~= nil and existing_condition.max ~= nil then
				existing_condition.max = math.max(existing_condition.max, condition.max)
			end
		end
	end

	recipe_or_entity.surface_conditions = surface_conditions
end

function Public.remove_surface_condition(recipe_or_entity, condition)
	if recipe_or_entity.surface_conditions then
		local conditions = util.table.deepcopy(recipe_or_entity.surface_conditions)
		local changed = false
		for i = #conditions, 1, -1 do
			local c = conditions[i]
			if type(condition) == "string" then
				if c.property == condition then
					table.remove(conditions, i)
					changed = true
				end
			elseif
				(c.property and condition.property and c.property == condition.property)
				and (not (condition.min or c.min) or (condition.min and c.min and c.min == condition.min))
				and (not (condition.max or c.max) or (condition.max and c.max and c.max == condition.max))
			then
				table.remove(conditions, i)
				changed = true
			end
		end

		if changed then
			recipe_or_entity.surface_conditions = conditions
		end
	end
end

local function create_is_planet_surface_property(planet_name)
	local property_name = "PlanetsLib-is-" .. planet_name
	local planet = data.raw["planet"][planet_name]
	assert(planet, "PlanetsLib.restrict_to_planet(): planet not found: " .. tostring(planet_name))
	planet["surface_properties"] = planet["surface_properties"] or {}
	if not data.raw["surface-property"][property_name] then
		data:extend{
			{
				name = property_name,
				type = "surface-property",
				hidden=true, --This line does nothing. The locale is what determines if surface properties are hidden or not.
				hidden_in_factoriopedia=true,
				default_value=0, --Default, planets are not a specific planet
				order="zzz",
				localised_name = {"surface-property-name.planet-str"},
				localised_unit_key = "surface-property-name.planet-str",
			}
		}
		planet["surface_properties"][property_name] = 1
	end
	return property_name

end

function Public.restrict_to_planet(recipe_or_entity, planet,invert)
	assert(recipe_or_entity,"PlanetsLib.restrict_to_planet(): Recipe_or_entity is a nil value.")
	local planet_name = type(planet) == "string" and planet or (planet and planet.name)
	assert(planet_name, "PlanetsLib.restrict_to_planet(): planet must be a name or a planet prototype.")
	local surface_conditions = recipe_or_entity.surface_conditions
			and util.table.deepcopy(recipe_or_entity.surface_conditions)
		or {}
	local property_name = create_is_planet_surface_property(planet_name)
	local condition_value = invert and 0 or 1

	-- Reuse an existing condition for the same property so repeated calls are idempotent
	-- and an `invert` call overrides the previous value instead of adding a contradiction.
	for i = 1, #surface_conditions do
		local existing = surface_conditions[i]
		if existing.property == property_name then
			existing.min = condition_value
			existing.max = condition_value
			recipe_or_entity.surface_conditions = surface_conditions
			return
		end
	end

	table.insert(surface_conditions, {
		property = property_name,
		min = condition_value,
		max = condition_value,
	})

	recipe_or_entity.surface_conditions = surface_conditions
end

--== Older APIs: ==--

local function exact_value(property, value) -- Returns a surface condition locking the acceptable range of values to exactly one.
	return {
		property = property,
		min = value,
		max = value,
	}
end

function Public.restrict_to_surface(planet) -- Returns a surface condition restricting prototype to the provided planet.
	return exact_value("planet-str", PlanetsLib.planet_str.get_planet_str_double(planet))
end

return Public
