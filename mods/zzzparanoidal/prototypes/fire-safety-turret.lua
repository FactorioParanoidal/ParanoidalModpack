-- Пожарные турели Paranoidal (идея — WaterTurret-revived, код свой; графика — базовая огнемётная
-- турель с перекраской). Питаются только водой, врагов не атакуют и урона не наносят.
-- Пока в турели есть вода, controls/fire-safety.lua гасит огонь в её зоне, а Flammable_Oils_QUICKFIX
-- не поджигает и не взрывает ничего в этой зоне. Зона = дальность и сектор attack_parameters:
-- движок сам рисует её при установке, как у огнемётной турели.
-- Параметры зон держать равными controls/fire-safety.lua (TIERS).
local TIERS = {
	{
		name = "pd-fire-safety-turret", range = 12, turn_range = 1, -- полный круг
		tint = {r = 0.45, g = 0.75, b = 1, a = 1}, max_health = 600,
		-- Уровень пулемётной турели (красная наука): всё открыто до «Основ работы с жидкостями».
		energy_required = 10,
		ingredients = {
			{type = "item", name = "iron-plate", amount = 25},
			{type = "item", name = "iron-gear-wheel", amount = 15},
			{type = "item", name = "motor", amount = 4},
			{type = "item", name = "bob-basic-circuit-board", amount = 6},
			{type = "item", name = "pipe", amount = 10},
			{type = "item", name = "offshore-pump", amount = 1},
		},
		technology = "basic-fluid-handling",
	},
	{
		name = "pd-fire-safety-turret-mk2", range = 24, turn_range = 1, -- полный круг
		tint = {r = 1, g = 0.35, b = 0.3, a = 1}, max_health = 900,
		-- Уровень огнемётной турели; всё открыто до «Транспортировки и хранения жидкостей 2».
		energy_required = 15,
		ingredients = {
			{type = "item", name = "pd-fire-safety-turret", amount = 1},
			{type = "item", name = "steel-plate", amount = 25},
			{type = "item", name = "bob-steel-gear-wheel", amount = 15},
			{type = "item", name = "bob-steel-pipe", amount = 15},
			{type = "item", name = "pump", amount = 2},
			{type = "item", name = "bob-basic-circuit-board", amount = 10},
		},
		technology = "bob-fluid-handling-2",
	},
}

local source = data.raw["fluid-turret"]["flamethrower-turret"]
if not source then return end
local item_source = data.raw.item["flamethrower-turret"]

-- Перекрасить все спрайты, кроме теней.
local function tint_sprites(t, tint)
	if type(t) ~= "table" then return end
	if (t.filename or t.filenames or t.stripes) and not t.draw_as_shadow then
		t.tint = tint
	end
	for _, v in pairs(t) do
		if type(v) == "table" then tint_sprites(v, tint) end
	end
end

-- Тип цели, которого нет ни у кого: турели никогда не стреляют.
local stream = table.deepcopy(data.raw.stream["flamethrower-fire-stream"])
stream.name = "pd-fire-safety-stream"
stream.action = nil
stream.final_action = nil
stream.smoke_sources = nil

-- Облачко пара на месте потушенного огня.
local steam = table.deepcopy(data.raw["trivial-smoke"]["turbine-smoke"])
steam.name = "pd-fire-safety-steam"
steam.color = {r = 0.95, g = 0.95, b = 1, a = 0.85}
steam.duration = 180
steam.fade_in_duration = 10
steam.fade_away_duration = 120
steam.start_scale = 0.8
steam.end_scale = 1.8
steam.show_when_smoke_off = true -- видно и при выключенном дыме в настройках графики

data:extend({{type = "trigger-target-type", name = "pd-fire-safety-no-target"}, stream, steam})

for index, tier in ipairs(TIERS) do
	local icons = {{icon = item_source and item_source.icon or source.icon,
		icon_size = item_source and item_source.icon_size or source.icon_size or 64, tint = tier.tint}}
	local description = {"entity-description." .. tier.name, tostring(tier.range)}

	local turret = table.deepcopy(source)
	turret.name = tier.name
	turret.localised_name = {"entity-name." .. tier.name}
	turret.localised_description = description
	turret.icon = nil
	turret.icons = icons
	turret.minable = {mining_time = 0.5, result = tier.name}
	turret.fast_replaceable_group = "pd-fire-safety-turret"
	turret.next_upgrade = TIERS[index + 1] and TIERS[index + 1].name or nil
	turret.max_health = tier.max_health
	turret.fluid_box.filter = "water" -- пар и другие жидкости не заливаются
	turret.attack_target_mask = {"pd-fire-safety-no-target"}
	turret.prepare_range = tier.range
	turret.radius_visualisation_specification = nil
	turret.attack_parameters.range = tier.range
	turret.attack_parameters.min_range = 0
	turret.attack_parameters.turn_range = tier.turn_range
	turret.attack_parameters.fluids = {{type = "water"}}
	turret.attack_parameters.ammo_type = {
		action = {type = "direct", action_delivery = {type = "stream", stream = stream.name}},
	}
	for _, key in ipairs({"folded_animation", "preparing_animation", "prepared_animation", "attacking_animation",
		"ending_attack_animation", "folding_animation", "graphics_set"}) do
		tint_sprites(turret[key], tier.tint)
	end

	local item = {
		type = "item",
		name = tier.name,
		localised_name = {"entity-name." .. tier.name},
		localised_description = description,
		icons = icons,
		subgroup = item_source and item_source.subgroup or "turret",
		order = (item_source and item_source.order or "") .. "-pd-fire-safety-" .. index,
		place_result = tier.name,
		stack_size = 50,
	}

	local recipe = {
		type = "recipe",
		name = tier.name,
		localised_name = {"entity-name." .. tier.name},
		enabled = false,
		energy_required = tier.energy_required,
		ingredients = tier.ingredients,
		results = {{type = "item", name = tier.name, amount = 1}},
	}

	data:extend({turret, item, recipe})

	local tech = data.raw.technology[tier.technology]
	if tech then
		tech.effects = tech.effects or {}
		table.insert(tech.effects, 1, {type = "unlock-recipe", recipe = tier.name})
	else
		log("fire-safety-turret: нет технологии " .. tier.technology)
	end
end
