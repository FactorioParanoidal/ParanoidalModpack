-- Paranoidal: lazy caches derived only from prototypes.
-- Prototypes are identical for every peer and cannot change without on_configuration_changed
-- (which reloads the Lua state), so these per-session tables are deterministic and need no storage.
-- They replace storage.allowedEntities / storage.fuelList / storage.ammoList that were rebuilt
-- by scanning every prototype on each configuration change and serialized into every save.

local config = require("config")

local this = {}

local pairs, ipairs = pairs, ipairs

-- Entity types that can never own an inventory in 2.0; skipped without inventory probes.
local NO_INVENTORY_TYPES = {}
for _, t in ipairs{
	"explosion", "smoke-with-trigger", "particle-source", "corpse", "rail-remnants", "tree", "fish",
	"resource", "projectile", "artillery-projectile", "stream", "beam", "fire", "sticker",
	"highlight-box", "arrow", "speech-bubble", "entity-ghost", "tile-ghost", "item-request-proxy",
	"deconstructible-tile-proxy", "item-entity", "cliff", "transport-belt", "underground-belt",
	"splitter", "linked-belt", "lane-splitter", "pipe", "pipe-to-ground", "electric-pole", "wall",
	"gate", "straight-rail", "curved-rail-a", "curved-rail-b", "half-diagonal-rail",
	"legacy-straight-rail", "legacy-curved-rail", "elevated-straight-rail", "elevated-curved-rail-a",
	"elevated-curved-rail-b", "elevated-half-diagonal-rail", "rail-ramp", "rail-support",
	"rail-signal", "rail-chain-signal", "land-mine", "unit", "combat-robot", "construction-robot",
	"logistic-robot", "capture-robot", "decider-combinator", "arithmetic-combinator",
	"constant-combinator", "selector-combinator", "power-switch", "programmable-speaker",
	"display-panel", "heat-pipe", "solar-panel", "accumulator", "storage-tank", "spider-leg",
} do NO_INVENTORY_TYPES[t] = true end

-- defines.inventory contains many aliases with the same numeric id; probe each id once.
local inventoryIds
local function getInventoryIds()
	if not inventoryIds then
		local seen = {}
		inventoryIds = {}
		for _, id in pairs(defines.inventory) do
			if not seen[id] then
				seen[id] = true
				inventoryIds[#inventoryIds + 1] = id
			end
		end
		table.sort(inventoryIds)
	end
	return inventoryIds
end

local function hasInventory(prototype)
	for _, id in ipairs(getInventoryIds()) do
		if prototype.get_inventory_size(id) then return true end
	end
	return false
end

-- name -> true/false: entity may receive items (has an inventory and is not ignored by config)
local allowed = {}

local function computeAllowed(name, prototype)
	local entityType = prototype.type
	return not NO_INVENTORY_TYPES[entityType]
		and not config.ignoredEntities[entityType]
		and not config.ignoredEntities[name]
		and hasInventory(prototype)
end

function this.isAllowedEntity(name)
	local value = allowed[name]
	if value == nil then
		local prototype = prototypes.entity[name]
		value = prototype ~= nil and computeAllowed(name, prototype) or false
		allowed[name] = value
	end
	return value
end

-- Full scan, only on demand (SHIFT+C, ignored-entity chooser) and once per session.
local allowedNames, allowedTypes
local function scanAll()
	if allowedNames then return end
	allowedNames, allowedTypes = {}, {}
	local typeSet = {}
	for name, prototype in pairs(prototypes.entity) do
		local value = allowed[name]
		if value == nil then
			value = computeAllowed(name, prototype)
			allowed[name] = value
		end
		if value then
			allowedNames[#allowedNames + 1] = name
			local entityType = prototype.type
			if not typeSet[entityType] then
				typeSet[entityType] = true
				allowedTypes[#allowedTypes + 1] = entityType
			end
		end
	end
	table.sort(allowedNames)
	table.sort(allowedTypes)
end

function this.allowedEntityNames()
	scanAll()
	return allowedNames
end

function this.allowedEntityTypes()
	scanAll()
	return allowedTypes
end

-- Technologies (other than ED's own) that unlock character logistic requests.
local logisticTechs
function this.logisticRequestTechs()
	if not logisticTechs then
		logisticTechs = {}
		for name, tech in pairs(prototypes.technology) do
			if name ~= "enable-logistics-tab" then
				for _, effect in pairs(tech.effects) do
					if effect.type == "character-logistic-requests" and effect.modifier then
						logisticTechs[#logisticTechs + 1] = name
						break
					end
				end
			end
		end
		table.sort(logisticTechs)
	end
	return logisticTechs
end

-- Fuel upgrade lists: fuel category -> item names, ascending (inferior first).
local fuelLists
function this.fuelList(category)
	if not fuelLists then
		fuelLists = {}
		local data = {}
		for name, item in pairs(prototypes.get_item_filtered{{ filter = "fuel" }}) do
			local cat = item.fuel_category
			if cat then
				data[name] = {
					item.fuel_value,
					item.fuel_acceleration_multiplier,
					item.fuel_top_speed_multiplier,
					item.fuel_emissions_multiplier,
				}
				local list = fuelLists[cat]
				if not list then list = {}; fuelLists[cat] = list end
				list[#list + 1] = name
			end
		end
		-- strict lexicographic order (the original or-chain was not a valid sort order)
		local function less(a, b)
			local da, db = data[a], data[b]
			for i = 1, 4 do
				if da[i] ~= db[i] then return da[i] < db[i] end
			end
			return a < b
		end
		for _, list in pairs(fuelLists) do table.sort(list, less) end
	end
	return fuelLists[category]
end

-- Ammo damage estimate (sum of damage effects, following nested results and created entities).
local MAX_DEPTH = 6
local damageFromActions

local function entityDamage(name, depth)
	local prototype = name and prototypes.entity[name]
	if not prototype then return 0 end
	return damageFromActions(prototype.attack_result, depth) + damageFromActions(prototype.final_attack_result, depth)
end

local function effectsDamage(effects, depth)
	local total = 0
	for _, effect in pairs(effects or {}) do
		local t = effect.type
		if t == "damage" and effect.damage then
			total = total + (effect.damage.amount or 0) * (effect.repeat_count or 1)
		elseif t == "nested-result" then
			total = total + damageFromActions(effect.action, depth)
		elseif t == "create-entity" or t == "create-explosion" or t == "create-fire" or t == "create-sticker" then
			total = total + entityDamage(effect.entity_name or effect.sticker, depth)
		end
	end
	return total
end

local function deliveryDamage(delivery, depth)
	local total = effectsDamage(delivery.target_effects, depth)
	local t = delivery.type
	if t == "projectile" or t == "artillery" then
		total = total + entityDamage(delivery.projectile, depth)
	elseif t == "stream" then
		total = total + entityDamage(delivery.stream, depth)
	elseif t == "beam" then
		total = total + entityDamage(delivery.beam, depth)
	end
	return total
end

function damageFromActions(actions, depth)
	depth = (depth or 0) + 1
	if not actions or depth > MAX_DEPTH then return 0 end
	local total = 0
	for _, action in pairs(actions) do
		local sum = 0
		for _, delivery in pairs(action.action_delivery or {}) do
			sum = sum + deliveryDamage(delivery, depth)
		end
		local multiplier = 1
		if action.type == "area" and action.radius then
			multiplier = action.radius * action.radius * math.pi
		end
		total = total + sum * multiplier * (action.repeat_count or 1)
	end
	return total
end

function this.ammoDamage(item)
	local ammoType = item.get_ammo_type()
	return ammoType and damageFromActions(ammoType.action) or 0
end

-- Ammo upgrade lists: ammo category -> item names, ascending damage (inferior first).
local ammoLists
function this.ammoList(category)
	if not ammoLists then
		ammoLists = {}
		local damage = {}
		for name, item in pairs(prototypes.get_item_filtered{{ filter = "type", type = "ammo" }}) do
			local cat = item.ammo_category
			if cat then
				damage[name] = this.ammoDamage(item)
				local list = ammoLists[cat.name]
				if not list then list = {}; ammoLists[cat.name] = list end
				list[#list + 1] = name
			end
		end
		local function less(a, b)
			if damage[a] ~= damage[b] then return damage[a] < damage[b] end
			return a < b
		end
		for _, list in pairs(ammoLists) do table.sort(list, less) end
	end
	return ammoLists[category]
end

-- Turret/wagon prototype name -> set of supported ammo categories.
local ammoCategories = {}
function this.supportsAmmo(entityPrototype, item)
	local name = entityPrototype.name
	local set = ammoCategories[name]
	if not set then
		set = {}
		local attack = entityPrototype.attack_parameters
		for _, category in pairs(attack and attack.ammo_categories or {}) do
			set[category] = true
		end
		ammoCategories[name] = set
	end
	local category = item.ammo_category
	return category ~= nil and set[category.name] == true
end

-- Furnace prototype name + item -> furnace has a recipe with this ingredient.
local smeltable = {}
function this.canSmelt(entityPrototype, item)
	local name = entityPrototype.name
	local byItem = smeltable[name]
	if not byItem then byItem = {}; smeltable[name] = byItem end
	local value = byItem[item]
	if value == nil then
		local filters = {}
		for category in pairs(entityPrototype.crafting_categories or {}) do
			filters[#filters + 1] = { filter = "category", category = category, mode = "or" }
		end
		if #filters == 0 then
			value = false
		else
			filters[#filters + 1] = { filter = "has-ingredient-item", elem_filters = {{ filter = "name", name = item }}, mode = "and" }
			value = #prototypes.get_recipe_filtered(filters) > 0
		end
		byItem[item] = value
	end
	return value
end

return this
