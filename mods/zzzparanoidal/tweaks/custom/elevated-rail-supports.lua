-- Эстакадные рельсы (встроенный мод elevated-rails без Space Age/Quality): дешёвый I тир на зелёной науке,
-- исследование кабеля в опорах (провода между опорами всех тиров, controls/rail-support-power.lua),
-- опоры II/III тира с большим пролётом и улучшением I → II → III.
-- Без elevated-rails файл ничего не делает.
if not (mods["elevated-rails"] and data.raw["rail-support"] and data.raw["rail-support"]["rail-support"]) then
	return
end

local BASE = "rail-support"
local POWER_TECH = "paranoidal-rail-support-power"
local SUPPORT_ICON = "__elevated-rails__/graphics/icons/rail-support.png"
local TECH_ICON = "__elevated-rails__/graphics/technology/elevated-rail.png"
local CABLE_ICON = "__base__/graphics/icons/copper-cable.png"

local function item(name, amount)
	return {type = "item", name = name, amount = amount}
end

local function science(count, packs)
	local ingredients = {}
	for _, pack in ipairs(packs) do
		ingredients[#ingredients + 1] = {pack, 1}
	end
	return {count = count, ingredients = ingredients, time = 30}
end

-- Эффект эволюции research_evolution_factor посчитан по прежней цене; research-evolution-icon
-- (последний require data-final-fixes) пересчитает его по новой.
local function drop_evolution_effect(tech)
	local effects = {}
	for _, effect in ipairs(tech.effects or {}) do
		local description = effect.type == "nothing" and type(effect.effect_description) == "table"
			and effect.effect_description[1]
		if not (description and string.find(description, "^research%-evolution%-factor%-effect")) then
			effects[#effects + 1] = effect
		end
	end
	tech.effects = effects
end

local function tint_sprites(node, tint)
	if type(node) ~= "table" then return end
	if node.filename or node.filenames then
		if not node.draw_as_shadow then node.tint = tint end
	end
	for _, child in pairs(node) do
		if type(child) == "table" then tint_sprites(child, tint) end
	end
end

local function support_icons(tier, tint)
	local icons = {{icon = SUPPORT_ICON, icon_size = 64, tint = tint}}
	icons[2] = {icon = "__zzzparanoidal__/graphics/num_" .. tier .. "-64.png", icon_size = 64, scale = 0.2, shift = {-10, -10}}
	return icons
end

-- Уровень и значок ветки рисуют общие маркеры сборки (tweaks/technology/icon-markers.lua) в конце файла.
local function technology_icons(tint)
	return {{icon = TECH_ICON, icon_size = 256, tint = tint}}
end

-------------------------------------------------------------------------------------------------
-- I тир: обычный бетон вместо железобетона, сразу после железной дороги за красную и зелёную науку.
local recipes = data.raw.recipe
if recipes[BASE] then
	recipes[BASE].ingredients = {item("concrete", 20), item("steel-plate", 10)}
end
if recipes["rail-ramp"] then
	recipes["rail-ramp"].ingredients = {item("concrete", 100), item("rail", 8), item("steel-plate", 10)}
end

local elevated_rail = data.raw.technology["elevated-rail"]
if elevated_rail then
	elevated_rail.prerequisites = {"railway"}
	elevated_rail.unit = science(100, {"automation-science-pack", "logistic-science-pack"})
	drop_evolution_effect(elevated_rail)
end

-------------------------------------------------------------------------------------------------
-- Опоры II и III тира.
local tiers = {
	{
		tier = 2, support_range = 16, max_health = 2000, tint = {r = 0.62, g = 0.78, b = 1},
		resistances = {
			{type = "physical", decrease = 5, percent = 30},
			{type = "impact", decrease = 60, percent = 70},
			{type = "explosion", decrease = 15, percent = 40},
			{type = "fire", percent = 100},
			{type = "acid", percent = 85},
			{type = "laser", percent = 75},
		},
		ingredients = {item(BASE, 1), item("refined-concrete", 20), item("steel-plate", 10), item("copper-cable", 10)},
		technology = {count = 200, packs = {"automation-science-pack", "logistic-science-pack", "chemical-science-pack"},
			prerequisites = {POWER_TECH, "chemical-science-pack"}},
	},
	{
		tier = 3, support_range = 24, max_health = 4000, tint = {r = 1, g = 0.68, b = 0.42},
		resistances = {
			{type = "physical", decrease = 8, percent = 40},
			{type = "impact", decrease = 80, percent = 80},
			{type = "explosion", decrease = 20, percent = 50},
			{type = "fire", percent = 100},
			{type = "acid", percent = 90},
			{type = "laser", percent = 80},
		},
		ingredients = {item("paranoidal-rail-support-2", 1), item("refined-concrete", 40), item("steel-plate", 20),
			item("intermediate-structure-components", 5), item("copper-cable", 20)},
		technology = {count = 300, packs = {"automation-science-pack", "logistic-science-pack", "chemical-science-pack",
			"production-science-pack"}, prerequisites = {"paranoidal-rail-support-2", "production-science-pack"}},
	},
}

local base_entity = data.raw["rail-support"][BASE]
local base_item = data.raw.item[BASE]
local base_recipe = recipes[BASE]
base_entity.fast_replaceable_group = "rail-support"
base_entity.next_upgrade = "paranoidal-rail-support-2"
base_item.icons = support_icons(1, nil)
base_item.icon = nil
base_entity.icons = support_icons(1, nil)
base_entity.icon = nil

local new_prototypes = {}
for _, def in ipairs(tiers) do
	local name = "paranoidal-rail-support-" .. def.tier
	local icons = support_icons(def.tier, def.tint)

	local entity = table.deepcopy(base_entity)
	entity.name = name
	entity.icon = nil
	entity.icons = icons
	entity.minable = {mining_time = 0.5, result = name}
	entity.max_health = def.max_health
	entity.support_range = def.support_range
	entity.resistances = def.resistances
	entity.fast_replaceable_group = "rail-support"
	entity.next_upgrade = def.tier == 2 and "paranoidal-rail-support-3" or nil
	entity.placeable_by = nil
	tint_sprites(entity.graphics_set, def.tint)

	local support_item = table.deepcopy(base_item)
	support_item.name = name
	support_item.icon = nil
	support_item.icons = icons
	support_item.place_result = name
	support_item.order = (base_item.order or "a[rail]-c[rail-support]") .. "-" .. def.tier

	local recipe = table.deepcopy(base_recipe)
	recipe.name = name
	recipe.enabled = false
	recipe.icon = nil
	recipe.icons = nil
	recipe.ingredients = {}
	for _, ingredient in ipairs(def.ingredients) do
		-- Optional Paranoidal intermediate only; own supports are added by data:extend below.
		if ingredient.name ~= "intermediate-structure-components" or data.raw.item[ingredient.name] then
			recipe.ingredients[#recipe.ingredients + 1] = ingredient
		end
	end
	recipe.results = {item(name, 1)}
	recipe.main_product = nil

	local technology = {
		type = "technology",
		name = name,
		-- A "-N" suffix makes the engine look up the level-less key technology-name.paranoidal-rail-support.
		localised_name = {"technology-name." .. name},
		localised_description = {"technology-description." .. name},
		icons = technology_icons(def.tint),
		effects = {{type = "unlock-recipe", recipe = name}},
		prerequisites = def.technology.prerequisites,
		unit = science(def.technology.count, def.technology.packs),
		order = "c-g-b-" .. def.tier,
	}

	for _, prototype in ipairs({entity, support_item, recipe, technology}) do
		new_prototypes[#new_prototypes + 1] = prototype
	end
end

-------------------------------------------------------------------------------------------------
-- Кабель в опорах: скрытый столб на каждой опоре, провод до соседних опор на двойной пролёт, без зоны питания.
new_prototypes[#new_prototypes + 1] = {
	type = "technology",
	name = POWER_TECH,
	icons = technology_icons(nil),
	effects = {{
		type = "nothing",
		effect_description = {"modifier-description." .. POWER_TECH},
		icon = CABLE_ICON,
		icon_size = 64,
	}},
	prerequisites = {"elevated-rail"},
	unit = science(150, {"automation-science-pack", "logistic-science-pack"}),
	order = "c-g-b-1",
}

local wire_template = data.raw["electric-pole"]["substation"]
local poles = {
	{support = BASE, tier = 1, range = base_entity.support_range},
	{support = "paranoidal-rail-support-2", tier = 2, range = tiers[1].support_range},
	{support = "paranoidal-rail-support-3", tier = 3, range = tiers[2].support_range},
}
for _, def in ipairs(poles) do
	local pole = table.deepcopy(wire_template)
	pole.name = "paranoidal-rail-support-pole-" .. def.tier
	pole.localised_name = {"entity-name.paranoidal-rail-support-pole"}
	pole.icon = nil
	pole.icons = support_icons(def.tier, def.tier > 1 and tiers[def.tier - 1].tint or nil)
	pole.flags = {"hide-alt-info", "no-copy-paste", "not-blueprintable", "not-deconstructable", "not-flammable",
		"not-on-map", "not-selectable-in-game", "not-upgradable", "placeable-off-grid", "placeable-player"}
	pole.hidden = true
	pole.hidden_in_factoriopedia = true
	pole.minable = nil
	pole.max_health = 1000
	pole.resistances = nil
	pole.corpse = nil
	pole.dying_explosion = nil
	pole.damaged_trigger_effect = nil
	pole.collision_box = {{0, 0}, {0, 0}}
	pole.collision_mask = {layers = {}, colliding_with_tiles_only = true, not_colliding_with_itself = true}
	pole.selection_box = nil
	pole.fast_replaceable_group = nil
	pole.next_upgrade = nil
	pole.maximum_wire_distance = math.min(def.range * 2, 64)
	pole.supply_area_distance = 0
	pole.draw_copper_wires = true
	pole.draw_circuit_wires = false
	pole.pictures = {filename = "__core__/graphics/empty.png", width = 1, height = 1, direction_count = 1}
	pole.connection_points = {pole.connection_points[1]}
	pole.active_picture = nil
	pole.water_reflection = nil
	pole.working_sound = nil
	pole.order = "z[rail-support-pole]-" .. def.tier
	new_prototypes[#new_prototypes + 1] = pole
end

-------------------------------------------------------------------------------------------------
-- Вкладка «Транспорт»: отдельная строка эстакад между рельсами и сигналами (после transport-menu-beta8).
local ROW = "paranoidal-transport-rail-elevated"
new_prototypes[#new_prototypes + 1] = {type = "item-subgroup", name = ROW, group = "transport", order = "a-01-1"}

data:extend(new_prototypes)

local row = {
	{"rail-planner", "rail-ramp", "01"},
	{"item", BASE, "02"},
	{"item", "paranoidal-rail-support-2", "03"},
	{"item", "paranoidal-rail-support-3", "04"},
}
for _, entry in ipairs(row) do
	local prototype = data.raw[entry[1]] and data.raw[entry[1]][entry[2]]
	if prototype then
		prototype.subgroup = ROW
		prototype.order = entry[3]
	end
	local recipe = recipes[entry[2]]
	if recipe then
		recipe.subgroup = ROW
		recipe.order = entry[3]
	end
end

-- Маркеры как у остальных технологий: римский уровень справа сверху, значок кабеля в рамке слева сверху.
require("tweaks.technology.icon-markers")({
	["elevated-rail"] = {level = 1},
	[POWER_TECH] = {badge = "copper-cable", badge_type = "item"},
	["paranoidal-rail-support-2"] = {level = 2},
	["paranoidal-rail-support-3"] = {level = 3},
})
