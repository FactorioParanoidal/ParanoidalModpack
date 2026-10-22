-- Пожарные турели Paranoidal (идея — WaterTurret-revived, код свой; графика — базовая огнемётная
-- турель с перекраской, без огонька поджига и свечения). Питаются только водой, врагов не атакуют и урона не наносят.
-- Движок рисует только основание: целей у турели нет, поэтому ствол у самой сущности пустой. Ствол рисует
-- control через rendering (анимации pd-fire-safety-gun-*/-ext-*) по ванильному циклу огнемётной турели:
-- выдвижение, поворот по 64 положениям, стрельба, складывание. Скорости, мёртвая зона и запас раскладывания —
-- из прототипа огнемётной турели; сектор — полный круг.
-- Пока в турели есть вода, controls/fire-safety.lua держит защиту в её зоне (Flammable_Oils_QUICKFIX
-- ничего там не поджигает и не взрывает), а при целях в зоне стреляет струями воды: гасит огонь
-- и кислоту на земле, рассеивает вражеские облака, снимает вредные стикеры со своих.
-- Зона = дальность и сектор attack_parameters: движок сам рисует её при установке.
-- Параметры турелей и списки целей передаются в control через mod-data "pd-fire-safety".
local TIERS = {
	{
		name = "pd-fire-safety-turret", range = 12, turn_range = 1, -- полный круг
		idle = 5, combat = 200, volume = 1000, -- вода в секунду: дежурно / при тушении; бак
		tint = {r = 0.45, g = 0.75, b = 1, a = 1}, max_health = 600, -- голубая
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
		idle = 10, combat = 400, volume = 2000,
		tint = {r = 0.3, g = 0.45, b = 1, a = 1}, max_health = 900, -- синяя
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

-- Струя воды: графика кислотной струи базовой игры (рассчитана на перекраску) в голубом цвете.
-- Создаётся только скриптом; первая капля вызывает script-эффект — тушение в точке попадания.
local WATER_TINT = {r = 0.55, g = 0.8, b = 1, a = 0.9}
local stream = {
	type = "stream",
	name = "pd-fire-safety-stream",
	flags = {"not-on-map"},
	hidden = true,
	particle_buffer_size = 60,
	particle_spawn_interval = 2,
	particle_spawn_timeout = 40, -- ~0,7 с потока на один выстрел; столько же ствол держит прицел (control)
	particle_vertical_acceleration = 0.0045,
	particle_horizontal_speed = 0.5,
	particle_horizontal_speed_deviation = 0.0035,
	particle_start_alpha = 0.5,
	particle_end_alpha = 1,
	particle_alpha_per_part = 0.8,
	particle_scale_per_part = 0.8,
	particle_loop_frame_count = 15,
	particle_fade_out_duration = 2,
	particle_loop_exit_threshold = 0.25,
	target_initial_position_only = true,
	initial_action = {
		type = "direct",
		action_delivery = {type = "instant", target_effects = {{type = "script", effect_id = "pd-fire-safety-hit"}}},
	},
	particle = {
		filename = "__base__/graphics/entity/acid-projectile/acid-projectile-head.png",
		line_length = 5, width = 42, height = 164, frame_count = 15,
		shift = util.by_pixel(-2, 31), tint = WATER_TINT, priority = "high", scale = 0.5,
	},
	spine_animation = {
		filename = "__base__/graphics/entity/acid-projectile/acid-projectile-tail.png",
		line_length = 5, width = 132, height = 20, frame_count = 15,
		shift = util.by_pixel(0, -1), tint = WATER_TINT, priority = "high", scale = 0.5,
	},
	shadow = {
		filename = "__base__/graphics/entity/acid-projectile/acid-projectile-shadow.png",
		line_length = 15, width = 42, height = 164, frame_count = 15,
		shift = util.by_pixel(-2, 31), draw_as_shadow = true, priority = "high", scale = 0.5,
	},
	oriented_particle = true,
	shadow_scale_enabled = true,
}

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

-- Что оставляют враги: обход атак и смертей юнитов, червей и спавнеров по ссылкам на другие
-- прототипы (снаряды, струи, взрывы, огонь, облака, стикеры). Графику и звук не обходим.
local REF_KEYS = {entity_name = true, sticker = true, stream = true, projectile = true, beam = true,
	dying_explosion = true}
local SKIP_KEYS = {animation = true, animations = true, run_animation = true, picture = true, pictures = true,
	graphics_set = true, sound = true, sounds = true, working_sound = true, icons = true, shadow = true,
	particle = true, spine_animation = true, water_reflection = true, integration_patch = true,
	walking_sound = true, dying_sound = true}
local CHAIN_TYPES = {"stream", "projectile", "artillery-projectile", "explosion", "beam", "fire",
	"smoke-with-trigger", "sticker"}

local function scan(roots)
	local found = {sticker = {}, ["smoke-with-trigger"] = {}}
	local seen_tables, seen_protos = {}, {}
	local walk
	local function follow(name)
		for _, kind in ipairs(CHAIN_TYPES) do
			local proto = data.raw[kind] and data.raw[kind][name]
			if proto then
				if found[kind] then found[kind][name] = true end
				local key = kind .. "/" .. name
				if not seen_protos[key] then
					seen_protos[key] = true
					walk(proto)
				end
			end
		end
	end
	walk = function(t)
		if seen_tables[t] then return end
		seen_tables[t] = true
		for k, v in pairs(t) do
			if type(v) == "table" then
				if not SKIP_KEYS[k] then
					walk(v)
					if k == "dying_explosion" then
						for _, e in pairs(v) do
							if type(e) == "table" and type(e.name) == "string" then follow(e.name) end
						end
					end
				end
			elseif type(v) == "string" and REF_KEYS[k] then
				follow(v)
			end
		end
	end
	for _, root in ipairs(roots) do walk(root) end
	return found
end

local function is_player_built(proto)
	for _, flag in pairs(proto.flags or {}) do
		if flag == "player-creation" then return true end
	end
	return false
end

local enemy_roots, player_roots = {}, {}
for _, kind in ipairs({"unit", "unit-spawner", "turret", "spider-unit", "segmented-unit"}) do
	for _, proto in pairs(data.raw[kind] or {}) do
		local list = (kind ~= "unit" and is_player_built(proto)) and player_roots or enemy_roots
		list[#list + 1] = proto
	end
end
for _, kind in ipairs({"capsule", "ammo", "ammo-turret", "electric-turret", "fluid-turret", "artillery-turret",
	"land-mine", "combat-robot", "gun"}) do
	for _, proto in pairs(data.raw[kind] or {}) do player_roots[#player_roots + 1] = proto end
end
local enemy = scan(enemy_roots)
local player = scan(player_roots)

-- Вредный стикер: урон, замедление игрока/техники, повышенное трение, поджог.
local function harmful(s)
	local damage = s.damage_per_tick
	if damage and (damage.amount or 0) > 0 then return true end
	if s.spread_fire then return true end
	for _, key in ipairs({"target_movement_modifier", "target_movement_modifier_from", "vehicle_speed_modifier",
		"vehicle_speed_modifier_from"}) do
		if s[key] and s[key] < 1 then return true end
	end
	for _, key in ipairs({"vehicle_friction_modifier", "vehicle_friction_modifier_from"}) do
		if s[key] and s[key] > 1 then return true end
	end
	return false
end

-- Стикеры снимаются только со своих, поэтому источник не важен: вражеские + все вредные.
local stickers, sticker_count = {}, 0
for name, proto in pairs(data.raw.sticker or {}) do
	if enemy.sticker[name] or harmful(proto) then
		stickers[name] = true
		sticker_count = sticker_count + 1
	end
end
-- Облака — только вражеские и не используемые оружием игрока (ядовитые капсулы не трогаем).
local clouds, cloud_names = {}, {}
for name in pairs(enemy["smoke-with-trigger"]) do
	if not player["smoke-with-trigger"][name] then
		clouds[name] = true
		cloud_names[#cloud_names + 1] = name
	end
end
table.sort(cloud_names)
log("fire-safety-turret: стикеров " .. sticker_count .. ", вражеских облаков " .. #cloud_names .. ": "
	.. table.concat(cloud_names, ", "))

-- Ванильные параметры наведения огнемётной турели.
local source_attack = source.attack_parameters or {}
local MIN_RANGE = source_attack.min_range or 6
local PREPARE_MARGIN = math.max(0, (source.prepare_range or 35) - (source_attack.range or 30))
local ROTATION_SPEED = source.rotation_speed or 0.015
local PREPARING_SPEED = source.preparing_speed or 0.08
local FOLDING_SPEED = source.folding_speed or 0.08

-- Анимации ствола для rendering. Листы и сдвиги — как в base/prototypes/entity/fire.lua; светящиеся слои
-- (gun-active) не берём. Тень не перекрашивается.
local GUN_DIR = "__base__/graphics/entity/flamethrower-turret/"
local EXT_ROW = {north = 0, east = 3, south = 2, west = 1} -- строки листа выдвижения (по 3 на сторону)
local EXT_FRAMES = 15
local function gun_animation(name, tint)
	local common = {line_length = 8, frame_count = 64, scale = 0.5, priority = "medium"}
	local function layer(t)
		for k, v in pairs(common) do t[k] = v end
		return t
	end
	return {type = "animation", name = name, layers = {
		layer({filename = GUN_DIR .. "flamethrower-turret-gun.png", width = 158, height = 128,
			shift = util.by_pixel(-1, -25), tint = tint}),
		layer({filename = GUN_DIR .. "flamethrower-turret-gun-mask.png", flags = {"mask"}, width = 144, height = 112,
			shift = util.by_pixel(-1, -28), tint = tint}),
		layer({filename = GUN_DIR .. "flamethrower-turret-gun-shadow.png", width = 182, height = 116,
			shift = util.by_pixel(31, -1), draw_as_shadow = true}),
	}}
end
local function extension_animation(name, row, tint)
	local function layer(t)
		t.line_length = 5
		t.frame_count = EXT_FRAMES
		t.scale = 0.5
		t.priority = "medium"
		t.y = t.height * 3 * row
		return t
	end
	return {type = "animation", name = name, layers = {
		layer({filename = GUN_DIR .. "flamethrower-turret-gun-extension.png", width = 152, height = 128,
			shift = util.by_pixel(0, -26), tint = tint}),
		layer({filename = GUN_DIR .. "flamethrower-turret-gun-extension-mask.png", flags = {"mask"}, width = 144,
			height = 120, shift = util.by_pixel(0, -26), tint = tint}),
		layer({filename = GUN_DIR .. "flamethrower-turret-gun-extension-shadow.png", width = 180, height = 114,
			shift = util.by_pixel(33, -1), draw_as_shadow = true}),
	}}
end

local function sound(name, base, count, volume)
	local variations = {}
	for i = 1, count do
		variations[i] = {filename = "__base__/sound/fight/" .. base .. "-" .. i .. ".ogg", volume = volume}
	end
	return {type = "sound", name = name, category = "game-effect", variations = variations}
end

local tiers = {}
local gun_prototypes = {}
for _, tier in ipairs(TIERS) do
	local extension = {}
	for dir, row in pairs(EXT_ROW) do
		extension[dir] = "pd-fire-safety-ext-" .. tier.name .. "-" .. dir
		gun_prototypes[#gun_prototypes + 1] = extension_animation(extension[dir], row, tier.tint)
	end
	local gun = "pd-fire-safety-gun-" .. tier.name
	gun_prototypes[#gun_prototypes + 1] = gun_animation(gun, tier.tint)
	tiers[tier.name] = {range = tier.range, turn_range = tier.turn_range, idle = tier.idle, combat = tier.combat,
		min_range = MIN_RANGE, prepare_range = tier.range + PREPARE_MARGIN, gun = gun, extension = extension}
end
data:extend(gun_prototypes)

data:extend({
	{type = "trigger-target-type", name = "pd-fire-safety-no-target"},
	stream,
	steam,
	sound("pd-fire-safety-activate", "flamethrower-turret-activate", 4, 0.3),
	sound("pd-fire-safety-deactivate", "flamethrower-turret-deactivate", 4, 0.2),
	{type = "mod-data", name = "pd-fire-safety", data = {tiers = tiers, stickers = stickers, clouds = clouds,
		gun = {rotation_speed = ROTATION_SPEED, preparing_speed = PREPARING_SPEED, folding_speed = FOLDING_SPEED,
			hold = stream.particle_spawn_timeout, extension_frames = EXT_FRAMES}}},
})

-- Огонёк поджига у сопла огнемёта воде не нужен.
local MUZZLE_KEYS = {"muzzle_animation", "muzzle_light", "folded_muzzle_animation_shift",
	"preparing_muzzle_animation_shift", "prepared_muzzle_animation_shift", "starting_attack_muzzle_animation_shift",
	"attacking_muzzle_animation_shift", "ending_attack_muzzle_animation_shift", "folding_muzzle_animation_shift"}

for index, tier in ipairs(TIERS) do
	local icons = {{icon = item_source and item_source.icon or source.icon,
		icon_size = item_source and item_source.icon_size or source.icon_size or 64, tint = tier.tint}}
	local description = {"entity-description." .. tier.name, tostring(tier.range), tostring(tier.idle),
		tostring(tier.combat)}

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
	turret.fluid_box.volume = tier.volume -- запас на цикл тушения (2 с при расходе combat)
	for _, key in ipairs(MUZZLE_KEYS) do turret[key] = nil end
	-- Ствол рисует control; у сущности — пустая картинка (в призраке и при установке виден только корпус).
	turret.folded_animation = {filename = "__core__/graphics/empty.png", size = 1, direction_count = 1}
	for _, key in ipairs({"preparing_animation", "prepared_animation", "attacking_animation",
		"ending_attack_animation", "folding_animation", "starting_attack_animation", "preparing_sound",
		"folding_sound"}) do
		turret[key] = nil
	end
	-- Тип цели, которого нет ни у кого: сам движок турелью никогда не стреляет, струи создаёт скрипт.
	turret.attack_target_mask = {"pd-fire-safety-no-target"}
	turret.prepare_range = tier.range + PREPARE_MARGIN
	turret.radius_visualisation_specification = nil
	turret.attack_parameters.range = tier.range
	turret.attack_parameters.min_range = MIN_RANGE
	turret.attack_parameters.turn_range = tier.turn_range
	turret.attack_parameters.fluids = {{type = "water"}}
	turret.attack_parameters.ammo_type = {
		action = {type = "direct", action_delivery = {type = "stream", stream = stream.name}},
	}
	tint_sprites(turret.graphics_set, tier.tint)

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
