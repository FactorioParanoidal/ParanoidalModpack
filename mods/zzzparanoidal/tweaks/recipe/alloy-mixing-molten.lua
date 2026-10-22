-- Смешивание расплавов в смесителе (issue #401, решения пользователя 2026-10-20).
-- 1. Жидкие двойники плавок Angels из слитков (расплав ×10 вместо слитков, тот же выход, 4 с);
--    железные — имена как в angelsextended-remelting 2.0.0, алюминий/титан — наше дополнение.
-- 2. Все эти рецепты и три прежних (кобальтовая сталь, нитинол, сталь -4) открываются
--    технологией смесителя своего тира; связи дерева не добавляются (рецепт может быть виден
--    раньше, чем открыт входной расплав).
-- 3. Иконка рецепта смесителя = иконка его пары из слитков + значок R.
-- После меню литья (иконки и ряды пар уже готовы) и production-chain-unlocks.

local R_LAYER = {
	icon = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png",
	icon_size = 64,
	tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
	scale = 0.32,
	shift = { -12, -12 },
}
local MIXER = "remelting-alloy-mixer-"
local CATEGORY = { "molten-alloy-mixing", "molten-alloy-mixing-2", "molten-alloy-mixing-3", "molten-alloy-mixing-4" }

-- Вход: "metal" (120 расплава), { "metal", N } (N расплава) или { item = name, amount = N }.
local function ingredient(spec)
	if type(spec) == "string" then
		return { type = "fluid", name = "angels-liquid-molten-" .. spec, amount = 120 }
	elseif spec.item then
		return { type = "item", name = spec.item, amount = spec.amount }
	end
	return { type = "fluid", name = "angels-liquid-molten-" .. spec[1], amount = spec[2] }
end

local function ingredient_exists(spec)
	if type(spec) == "table" and spec.item then return data.raw.item[spec.item] ~= nil end
	return data.raw.fluid["angels-liquid-molten-" .. (type(spec) == "string" and spec or spec[1])] ~= nil
end

-- name, тир, пара из слитков, входы, выход
local new_recipes = {
	{ "molten-manganese-iron-alloy-mixing", 1, "angels-liquid-molten-iron-2", { "iron", "manganese" }, "iron", 240 },
	{ "molten-silicon-iron-alloy-mixing", 1, "angels-liquid-molten-iron-3", { "iron", "silicon" }, "iron", 240 },
	{ "molten-coni-iron-alloy-mixing", 2, "angels-liquid-molten-iron-4", { "iron", "cobalt", "nickel" }, "iron", 360 },
	{ "molten-crni-iron-alloy-mixing", 3, "angels-liquid-molten-iron-5", { "iron", "chrome", "nickel" }, "iron", 360 },
	{ "molten-manganese-aluminium-alloy-mixing", 2, "angels-liquid-molten-aluminium-2", { "aluminium", "manganese" }, "aluminium", 240 },
	{ "molten-manganese-titanium-alloy-mixing", 3, "angels-liquid-molten-titanium-2", { "titanium", "manganese" }, "titanium", 240 },
	{ "molten-cocr-titanium-alloy-mixing", 4, "angels-liquid-molten-titanium-5", { "titanium", "cobalt", "chrome" }, "titanium", 360 },
	{ "molten-sicu-aluminium-alloy-mixing", 3, "angels-liquid-molten-aluminium-3", { "aluminium", "silicon", "copper" }, "aluminium", 360 },
	{ "molten-nickel-titanium-alloy-mixing", 3, "angels-liquid-molten-titanium-3", { "titanium", "nickel" }, "titanium", 240 },
	{ "molten-alsn-titanium-alloy-mixing", 4, "angels-liquid-molten-titanium-4", { "titanium", "aluminium", "tin" }, "titanium", 360 },
	{ "molten-brass-alloy-mixing-4", 3, "angels-brass-smelting-4",
		{ { "copper", 180 }, { "zinc", 120 }, { item = "clowns-solid-white-phosphorus", amount = 6 } }, "brass", 360 },
}

-- Прежние рецепты: перенос в смеситель тира (nil — открытие не трогаем) и пара для иконки.
local old_recipes = {
	{ "molten-brass-alloy-mixing-1", nil, "angels-liquid-molten-brass" },
	{ "molten-brass-alloy-mixing-2", nil, "angels-liquid-molten-brass-2" },
	{ "molten-brass-alloy-mixing-3", nil, "angels-liquid-molten-brass-3" },
	{ "molten-bronze-alloy-mixing-1", nil, "angels-liquid-molten-bronze" },
	{ "molten-bronze-alloy-mixing-2", nil, "angels-liquid-molten-bronze-2" },
	{ "molten-bronze-alloy-mixing-3", nil, "angels-liquid-molten-bronze-3" },
	{ "molten-solder-alloy-mixing-1", nil, "angels-liquid-molten-solder" },
	{ "molten-solder-alloy-mixing-2", nil, "angels-liquid-molten-solder-2" },
	{ "molten-solder-alloy-mixing-3", nil, "angels-liquid-molten-solder-3" },
	{ "molten-steel-alloy-mixing", nil, "angels-liquid-molten-steel" },
	{ "molten-steel-alloy-mixing-2", nil, "angels-liquid-molten-steel-2" },
	{ "molten-steel-alloy-mixing-3", nil, "angels-liquid-molten-steel-3" },
	{ "molten-steel-alloy-mixing-cobalt-nickel", nil, "angels-liquid-molten-steel-4" },
	{ "molten-steel-alloy-mixing-4", 3, "angels-liquid-molten-steel-5" },
	{ "molten-cobalt-steel-alloy-mixing-1", 2, nil },
	{ "molten-nitinol-alloy-mixing-1", 3, nil },
}

local function twin_icons(twin)
	local icons
	if twin.icons then
		icons = table.deepcopy(twin.icons)
	elseif twin.icon then
		icons = { { icon = twin.icon, icon_size = twin.icon_size or 64 } }
	else
		return nil
	end
	table.insert(icons, table.deepcopy(R_LAYER))
	return icons
end

local function remove_unlock_everywhere(recipe_name)
	for _, technology in pairs(data.raw.technology) do
		local effects = technology.effects
		if effects then
			for index = #effects, 1, -1 do
				if effects[index].type == "unlock-recipe" and effects[index].recipe == recipe_name then
					table.remove(effects, index)
				end
			end
		end
	end
end

local function unlock_in_mixer(recipe_name, tier)
	local technology = data.raw.technology[MIXER .. tier]
	if not technology then
		log("[alloy-mixing-molten] missing technology " .. MIXER .. tier)
		return
	end
	remove_unlock_everywhere(recipe_name)
	technology.effects = technology.effects or {}
	table.insert(technology.effects, { type = "unlock-recipe", recipe = recipe_name })
end

local function last_order(subgroup)
	local last = ""
	for _, recipe in pairs(data.raw.recipe) do
		if recipe.subgroup == subgroup and (recipe.order or "") > last then last = recipe.order end
	end
	return last
end

local added = {}
for index, spec in ipairs(new_recipes) do
	local name, tier, twin_name, inputs, output, amount = table.unpack(spec)
	local twin = data.raw.recipe[twin_name]
	local ok = twin and not twin.hidden and not data.raw.recipe[name]
	for _, input in ipairs(inputs) do
		ok = ok and ingredient_exists(input)
	end
	if ok then
		local ingredients = {}
		for _, input in ipairs(inputs) do table.insert(ingredients, ingredient(input)) end
		local result = "angels-liquid-molten-" .. output
		local subgroup = twin.subgroup
		table.insert(added, {
			type = "recipe",
			name = name,
			localised_name = { "fluid-name." .. result },
			category = CATEGORY[tier],
			subgroup = subgroup,
			order = last_order(subgroup) .. "-" .. string.format("%02d", index),
			enabled = false,
			energy_required = 4,
			ingredients = ingredients,
			results = { { type = "fluid", name = result, amount = amount } },
			icons = twin_icons(twin),
		})
	else
		log("[alloy-mixing-molten] skipped " .. name)
	end
end
if #added > 0 then data:extend(added) end
for _, recipe in ipairs(added) do
	unlock_in_mixer(recipe.name, tonumber(recipe.category:match("%-(%d)$")) or 1)
end

for _, spec in ipairs(old_recipes) do
	local name, tier, twin_name = spec[1], spec[2], spec[3]
	local recipe = data.raw.recipe[name]
	if recipe then
		if tier then
			recipe.category = CATEGORY[tier]
			unlock_in_mixer(name, tier)
		end
		local twin = twin_name and data.raw.recipe[twin_name]
		local icons = twin and twin_icons(twin)
		if icons then
			recipe.icons = icons
			recipe.icon = nil
			recipe.icon_size = nil
		end
	end
end
