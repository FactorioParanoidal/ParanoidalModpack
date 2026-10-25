-- Paranoidal fork: small helpers for explicit 2.0 recipe tables. Missing recipes are an error on purpose:
-- a silent no-op would hide a renamed Yuoki recipe.
local P = {}

function P.recipe(name)
	local recipe = data.raw.recipe[name]
	if not recipe then
		error("Yuoki (Paranoidal): recipe not found: " .. name)
	end
	return recipe
end

-- {"name", amount} -> item; {"name", amount, "fluid"} -> fluid; full tables are passed through.
local function entry(e)
	if e.name then
		return e
	end
	return { type = e[3] or "item", name = e[1], amount = e[2] }
end

local function list(entries)
	local out = {}
	for _, e in ipairs(entries) do
		out[#out + 1] = entry(e)
	end
	return out
end
P.list = list

function P.ingredients(name, entries)
	P.recipe(name).ingredients = list(entries)
end

function P.results(name, entries, main_product)
	local recipe = P.recipe(name)
	recipe.results = list(entries)
	if main_product ~= nil then
		recipe.main_product = main_product
	end
end

function P.set(name, fields)
	local recipe = P.recipe(name)
	for k, v in pairs(fields) do
		recipe[k] = v
	end
end

function P.category(names, category)
	for _, name in ipairs(names) do
		P.recipe(name).category = category
	end
end

-- Adds or replaces one ingredient by name.
function P.upsert_ingredient(name, e)
	local recipe = P.recipe(name)
	e = entry(e)
	for _, ing in pairs(recipe.ingredients or {}) do
		if ing.name == e.name then
			ing.amount = e.amount
			return
		end
	end
	recipe.ingredients = recipe.ingredients or {}
	table.insert(recipe.ingredients, e)
end

function P.result_amount(name, result_name, amount)
	for _, r in pairs(P.recipe(name).results or {}) do
		if r.name == result_name then
			r.amount = amount
			return
		end
	end
	error("Yuoki (Paranoidal): " .. name .. " has no result " .. result_name)
end

function P.entity(type_name, name)
	local e = data.raw[type_name] and data.raw[type_name][name]
	if not e then
		error("Yuoki (Paranoidal): prototype not found: " .. type_name .. "/" .. name)
	end
	return e
end

-- First existing item of a list (data-final-fixes only: every mod is loaded by then).
function P.first_item(names)
	for _, n in ipairs(names) do
		for _, t in pairs({ "item", "ammo", "gun", "armor", "repair-tool", "capsule", "module", "tool", "item-with-entity-data" }) do
			if data.raw[t] and data.raw[t][n] then
				return n
			end
		end
	end
	error("Yuoki (Paranoidal): none of these items exist: " .. table.concat(names, ", "))
end

return P
