-- Зенитные турели 1–3 (решение пользователя 2026-10-27): копии снайперских турелей Bob после всех правок
-- сборки (характеристики, открытия, бонусы урона), отличия только:
--  * своя дальность и минимальный радиус (RANGES) и свой рецепт из снайперки того же тира (RECIPES),
--    решение пользователя 2026-10-29;
--  * стреляют втрое чаще (cooldown / 3), один выстрел = один патрон и одно попадание;
--  * целятся только в летающих врагов: тип цели "pd-air-unit" есть только у летающих юнитов
--    (RampantFixed flyers, включая чемпионов, и любые юниты со слоем отрисовки air-object);
--  * трёхствольная графика (graphics/anti-air-turret, собрана из листов reskins-bobs) и иконка;
--  * каждый выстрел движок выпускает из одного из трёх стволов наугад (projectile_creation_offsets,
--    как у ракетной турели Space Age; без скрипта).
-- Ранговые копии HeroTurretRedux (он грузится после zzz) создаются из этих прототипов сами.
local AIR = "pd-air-unit"
local SNIPER = "bob-sniper-turret-"
local NAME = "pd-anti-air-turret-"
local TIERS = 3
local SPRITES = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-"
local OWN = "__zzzparanoidal__/graphics/anti-air-turret/anti-air-turret-"
-- Слои иконки снайперки (меню Beta 8 и reskins) → трёхствольные слои.
local ICONS = {
	["__zzzparanoidal__/graphics/bob-combat-menu-beta8/f801f3d74997921484ac.png"] = OWN .. "icon-base.png",
	["__zzzparanoidal__/graphics/bob-combat-menu-beta8/3d3606bdb20267baa67e.png"] = OWN .. "icon-mask.png",
	["__zzzparanoidal__/graphics/bob-combat-menu-beta8/84345afb20b48c763e0c.png"] = OWN .. "icon-highlights.png",
	["__reskins-bobs__/graphics/icons/warfare/sniper-turret/sniper-turret-icon-base.png"] = OWN .. "icon-base.png",
	["__reskins-bobs__/graphics/icons/warfare/sniper-turret/sniper-turret-icon-mask.png"] = OWN .. "icon-mask.png",
	["__reskins-bobs__/graphics/icons/warfare/sniper-turret/sniper-turret-icon-highlights.png"] = OWN .. "icon-highlights.png",
}
local SUBGROUP = "paranoidal-split-defense-anti-air-turrets"
local RANGES = {{range = 25, min_range = 5}, {range = 30, min_range = 7}, {range = 35, min_range = 10}}
local function item(name, amount)
	return {type = "item", name = name, amount = amount}
end
local RECIPES = {
	{item(SNIPER .. 1, 1), item("bob-steel-bearing", 10), item("steel-plate", 10)},
	{item(SNIPER .. 2, 1), item("bob-cobalt-steel-bearing", 10), item("bob-invar-alloy", 10)},
	{item(SNIPER .. 3, 1), item("bob-titanium-bearing", 10), item("bob-titanium-plate", 10)},
}
-- Стволы на листах спрайтов разнесены на 19 px исходника (scale 0.5) = 9.5 px игры поперёк ствола.
local BARREL_OFFSETS = {{0, 0}, {9.5 / 32, 0}, {-9.5 / 32, 0}}

for tier = 1, TIERS do
	if not (data.raw["ammo-turret"][SNIPER .. tier] and data.raw.item[SNIPER .. tier] and data.raw.recipe[SNIPER .. tier]) then
		log("anti-air-turret: нет снайперской турели " .. SNIPER .. tier .. ", зенитные турели не созданы")
		return
	end
end

-- Тип цели и летающие враги -------------------------------------------------------------------------------
data:extend({{type = "trigger-target-type", name = AIR}})

local function is_flyer(unit)
	if unit.render_layer == "air-object" then return true end
	local layers = unit.collision_mask and unit.collision_mask.layers
	return layers ~= nil and layers["rampantFixed-flyer"] == true
end

-- Без явной маски у юнита движок берёт {"common", "ground-unit"} (utility-constants
-- default_trigger_target_mask_by_type): прежние типы сохраняются, остальные турели бьют летающих как раньше.
local flyers = 0
for _, unit in pairs(data.raw.unit or {}) do
	if is_flyer(unit) then
		local mask = unit.trigger_target_mask and table.deepcopy(unit.trigger_target_mask) or {"common", "ground-unit"}
		local present = false
		for _, value in pairs(mask) do
			if value == AIR then present = true end
		end
		if not present then mask[#mask + 1] = AIR end
		unit.trigger_target_mask = mask
		flyers = flyers + 1
	end
end
log("anti-air-turret: летающих юнитов с типом цели " .. AIR .. ": " .. flyers)

-- Графика ----------------------------------------------------------------------------------------------------
local function remap_sprites(t, seen)
	if type(t) ~= "table" or seen[t] then return end
	seen[t] = true
	for key, value in pairs(t) do
		if type(value) == "string" and (key == "filename" or type(key) == "number") then
			local rest = value:sub(1, #SPRITES) == SPRITES and value:sub(#SPRITES + 1)
			if rest and (rest:find("^shooting") or rest:find("^raising")) then t[key] = OWN .. rest end
		elseif type(value) == "table" then
			remap_sprites(value, seen)
		end
	end
end

local function remap_icons(icons)
	icons = table.deepcopy(icons)
	for _, layer in pairs(icons) do
		if ICONS[layer.icon] then layer.icon = ICONS[layer.icon] end
	end
	return icons
end

local function icons_of(proto)
	if proto.icons then return proto.icons end
	if proto.icon then return {{icon = proto.icon, icon_size = proto.icon_size or 64}} end
end

-- Подгруппа меню сразу под снайперскими турелями --------------------------------------------------------
local sniper_item = data.raw.item[SNIPER .. 1]
local sniper_subgroup = data.raw["item-subgroup"][data.raw.recipe[SNIPER .. 1].subgroup or sniper_item.subgroup or ""]
data:extend({{
	type = "item-subgroup",
	name = SUBGROUP,
	group = sniper_subgroup and sniper_subgroup.group or "defensive-structure",
	order = (sniper_subgroup and sniper_subgroup.order or "") .. "-b",
}})

-- Турели, предметы, рецепты --------------------------------------------------------------------------------
local SNIPER_PATTERN = "^bob%-sniper%-turret%-(%d+)$"
local function rename(name)
	local tier = type(name) == "string" and name:match(SNIPER_PATTERN)
	return tier and NAME .. tier or name
end

for tier = 1, TIERS do
	local name = NAME .. tier
	local sniper = data.raw["ammo-turret"][SNIPER .. tier]
	local recipe_source = data.raw.recipe[SNIPER .. tier]
	local icons = remap_icons(icons_of(recipe_source) or icons_of(data.raw.item[SNIPER .. tier]) or icons_of(sniper))
	local localised_name = {"entity-name." .. name}
	local localised_description = {"entity-description." .. name}

	local turret = table.deepcopy(sniper)
	turret.name = name
	turret.localised_name = localised_name
	turret.localised_description = localised_description
	turret.icon = nil
	turret.icons = icons
	turret.minable = turret.minable and table.deepcopy(turret.minable) or {mining_time = 0.5}
	turret.minable.result = name
	turret.minable.results = nil
	turret.placeable_by = nil
	turret.next_upgrade = tier < TIERS and NAME .. (tier + 1) or nil
	turret.fast_replaceable_group = "pd-anti-air-turret"
	turret.attack_target_mask = {AIR}
	turret.attack_parameters.cooldown = sniper.attack_parameters.cooldown / 3
	turret.attack_parameters.range = RANGES[tier].range
	turret.attack_parameters.min_range = RANGES[tier].min_range
	turret.prepare_range = RANGES[tier].range + 2
	turret.attack_parameters.projectile_creation_offsets = table.deepcopy(BARREL_OFFSETS)
	remap_sprites(turret, {})

	local item = table.deepcopy(data.raw.item[SNIPER .. tier])
	item.name = name
	item.localised_name = localised_name
	item.localised_description = localised_description
	item.icon = nil
	item.icons = icons
	item.place_result = name
	item.subgroup = SUBGROUP
	item.order = string.format("%02d", tier)

	local recipe = table.deepcopy(recipe_source)
	recipe.name = name
	recipe.localised_name = localised_name
	recipe.localised_description = nil
	recipe.icon = nil
	recipe.icons = icons
	recipe.subgroup = SUBGROUP
	recipe.order = string.format("%02d", tier)
	recipe.ingredients = table.deepcopy(RECIPES[tier])
	for _, entry in pairs(recipe.results or {}) do
		if entry.name then entry.name = rename(entry.name) end
	end
	if recipe.main_product then recipe.main_product = rename(recipe.main_product) end

	data:extend({turret, item, recipe})
end

-- Открытие вместе со снайперскими и те же бонусы урона турели -------------------------------------------
local unlocks, bonuses = 0, 0
for _, tech in pairs(data.raw.technology) do
	local effects = tech.effects
	if effects then
		for i = #effects, 1, -1 do
			local effect = effects[i]
			if effect.type == "unlock-recipe" and rename(effect.recipe) ~= effect.recipe then
				table.insert(effects, i + 1, {type = "unlock-recipe", recipe = rename(effect.recipe)})
				unlocks = unlocks + 1
			elseif effect.type == "turret-attack" and rename(effect.turret_id) ~= effect.turret_id then
				local copy = table.deepcopy(effect)
				copy.turret_id = rename(effect.turret_id)
				table.insert(effects, i + 1, copy)
				bonuses = bonuses + 1
			end
		end
	end
end
log("anti-air-turret: открытий рецептов " .. unlocks .. ", бонусов урона турели " .. bonuses)

-- Исследования снайперок открывают и зенитки: своё название (общий ключ bob-sniper-turrets перебивает ParanoidalLocale).
for tier = 1, TIERS do
	local tech = data.raw.technology["bob-sniper-turrets-" .. tier]
	if tech then tech.localised_name = {"technology-name.pd-sniper-anti-air-turrets-" .. tier} end
end
