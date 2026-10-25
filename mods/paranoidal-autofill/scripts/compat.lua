-- Which buildings take fuel/ammo and which items fit them.
-- Derived from prototypes only, so it is kept in a Lua local (not storage) and rebuilt
-- lazily; every peer computes the same result.
--
-- Variants: buildings that scripts put in place of a hand-placed one share its rule and are
-- not offered in the picker:
--   * copies without an own item (Cursed-FMD per-ore drills): items_to_place_this[1] gives
--     the main building;
--   * HeroTurretRedux ranks "hero-turret-N-for-<base>".

local M = {}

-- Entity types with an ammo inventory that a script can fill.
-- Other types with attack_parameters (electric/fluid turrets) have no ammo inventory.
local AMMO_INVENTORY = {
	["ammo-turret"] = defines.inventory.turret_ammo,
	["artillery-turret"] = defines.inventory.artillery_turret_ammo,
	["artillery-wagon"] = defines.inventory.artillery_wagon_ammo,
	["car"] = defines.inventory.car_ammo,
	["spider-vehicle"] = defines.inventory.spider_ammo,
}

-- Entities whose mined products count as raw (coal, wood, ...): available without a recipe.
local RAW_SOURCES = { "resource", "tree", "simple-entity", "fish", "plant" }

local cache

local function categories_of(attack_parameters, into)
	local cats = attack_parameters and attack_parameters.ammo_categories
	if not cats then return end
	for _, cat in pairs(cats) do
		if type(cat) == "string" then into[cat] = true end
	end
end

local function set_key(set)
	local list = {}
	for k in pairs(set) do list[#list + 1] = k end
	table.sort(list)
	return table.concat(list, "|")
end

local function compartments_of(proto)
	local compartments = {}
	local burner = proto.burner_prototype
	if burner and (burner.fuel_inventory_size or 0) > 0 and burner.fuel_categories then
		local cats = {}
		for cat in pairs(burner.fuel_categories) do cats[cat] = true end
		if next(cats) then
			compartments[#compartments + 1] = { kind = "fuel", cats = cats }
		end
	end
	local inv = AMMO_INVENTORY[proto.type]
	if inv and (proto.get_inventory_size(inv) or 0) > 0 then
		local seen = {}
		local function add(cats)
			if not next(cats) then return end
			local key = set_key(cats)
			if seen[key] then return end
			seen[key] = true
			compartments[#compartments + 1] = { kind = "ammo", inventory = inv, cats = cats }
		end
		if proto.type == "ammo-turret" then
			local cats = {}
			categories_of(proto.attack_parameters, cats)
			add(cats)
		end
		for _, gun in pairs(proto.indexed_guns or {}) do
			local cats = {}
			categories_of(gun.attack_parameters, cats)
			add(cats)
		end
	end
	return compartments
end

-- Non-hidden items whose place_result is this very entity.
local function own_items(proto)
	local list = {}
	for _, it in pairs(proto.items_to_place_this or {}) do
		local item = prototypes.item[it.name]
		if item and not item.hidden and item.place_result and item.place_result.name == proto.name then
			list[#list + 1] = item.name
		end
	end
	return list
end

local function build()
	local fuel_items, ammo_items = {}, {}   -- category -> list of item names
	local item_fuel, item_ammo = {}, {}     -- item name -> category
	for name, item in pairs(prototypes.item) do
		if not item.hidden then
			local fc = item.fuel_category
			if type(fc) == "string" then
				item_fuel[name] = fc
				fuel_items[fc] = fuel_items[fc] or {}
				table.insert(fuel_items[fc], name)
			end
			local ac = item.ammo_category
			if ac and ac.name then
				item_ammo[name] = ac.name
				ammo_items[ac.name] = ammo_items[ac.name] or {}
				table.insert(ammo_items[ac.name], name)
			end
		end
	end

	-- Every building that takes something, variants included.
	local entities = {}
	for name, proto in pairs(prototypes.entity) do
		if not proto.hidden then
			local compartments = compartments_of(proto)
			if #compartments > 0 then
				local items, item_set = {}, {}
				for _, comp in ipairs(compartments) do
					local by_cat = comp.kind == "fuel" and fuel_items or ammo_items
					for cat in pairs(comp.cats) do
						for _, item in ipairs(by_cat[cat] or {}) do
							if not item_set[item] then
								item_set[item] = true
								items[#items + 1] = item
							end
						end
					end
				end
				if #items > 0 then
					table.sort(items)
					entities[name] = { compartments = compartments, items = items, item_set = item_set }
				end
			end
		end
	end

	-- Main buildings (offered in the picker) and variants.
	local canonical, variants, entity_names, place_items = {}, {}, {}, {}
	for name in pairs(entities) do
		local proto = prototypes.entity[name]
		local base = string.match(name, "^hero%-turret%-%d+%-for%-(.+)$")
		local main
		if base then
			main = base
		else
			local own = own_items(proto)
			if #own > 0 then
				main = name
				place_items[name] = own
			else
				local first = (proto.items_to_place_this or {})[1]
				local item = first and prototypes.item[first.name]
				local target = item and item.place_result and item.place_result.name
				if target and target ~= name then main = target end
			end
		end
		if main and main ~= name then
			-- A variant only counts if its main building is offered itself.
			canonical[name] = main
		elseif main == name then
			canonical[name] = name
			entity_names[#entity_names + 1] = name
		end
	end
	for name, main in pairs(canonical) do
		if main ~= name then
			if canonical[main] == main then
				variants[main] = variants[main] or {}
				table.insert(variants[main], name)
			else
				canonical[name] = nil
			end
		end
	end
	table.sort(entity_names)
	for _, list in pairs(variants) do table.sort(list) end

	-- Recipes that make the items of interest. Hidden ones (recycling, scripts) and
	-- loops that give back an ingredient (hero ranks, defect repair) do not count.
	local wanted = {}
	for item in pairs(item_fuel) do wanted[item] = true end
	for item in pairs(item_ammo) do wanted[item] = true end
	for _, list in pairs(place_items) do
		for _, item in ipairs(list) do wanted[item] = true end
	end
	local item_recipes = {}
	for rname, recipe in pairs(prototypes.recipe) do
		if not recipe.hidden and not string.find(recipe.category or "", "recycling", 1, true) then
			local inputs = {}
			for _, ing in pairs(recipe.ingredients or {}) do
				if ing.type == "item" then inputs[ing.name] = true end
			end
			for _, product in pairs(recipe.products or {}) do
				local pname = product.name
				if product.type == "item" and wanted[pname] and not inputs[pname] then
					item_recipes[pname] = item_recipes[pname] or {}
					table.insert(item_recipes[pname], rname)
				end
			end
		end
	end

	local raw = {}
	for _, proto in pairs(prototypes.get_entity_filtered({ { filter = "type", type = RAW_SOURCES } })) do
		local mp = proto.mineable_properties
		if mp and mp.minable and mp.products then
			for _, product in pairs(mp.products) do
				if product.type == "item" then raw[product.name] = true end
			end
		end
	end

	return {
		entities = entities,
		entity_names = entity_names,
		canonical = canonical,
		variants = variants,
		place_items = place_items,
		item_recipes = item_recipes,
		raw = raw,
		item_fuel = item_fuel,
		item_ammo = item_ammo,
	}
end

function M.get()
	if not cache then cache = build() end
	return cache
end

function M.reset()
	cache = nil
end

-- Info about a building (variants included), or nil if it takes no fuel/ammo.
function M.entity(name)
	return M.get().entities[name]
end

-- Main building for a building or its variant, nil if it is not offered.
function M.canonical(name)
	return M.get().canonical[name]
end

function M.variants(name)
	return M.get().variants[name]
end

function M.fits(comp, item_name)
	local c = M.get()
	if comp.kind == "fuel" then
		local cat = c.item_fuel[item_name]
		return cat ~= nil and comp.cats[cat] == true
	end
	local cat = c.item_ammo[item_name]
	return cat ~= nil and comp.cats[cat] == true
end

local function recipe_enabled(force, item)
	local list = M.get().item_recipes[item]
	if not list then return false end
	local recipes = force.recipes
	for _, rname in ipairs(list) do
		local r = recipes[rname]
		if r and r.enabled then return true end
	end
	return false
end

-- Fuel/ammo the force can get: a researched recipe, a raw resource, or an item with no recipe.
function M.item_learned(force, item)
	local c = M.get()
	if c.raw[item] or not c.item_recipes[item] then return true end
	return recipe_enabled(force, item)
end

-- A building is learned when one of its own items has a researched recipe.
function M.entity_learned(force, name)
	for _, item in ipairs(M.get().place_items[name] or {}) do
		if recipe_enabled(force, item) then return true end
	end
	return false
end

return M
