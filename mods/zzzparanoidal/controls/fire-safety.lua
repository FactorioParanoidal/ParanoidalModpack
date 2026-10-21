-- Пожарные турели (prototypes/fire-safety-turret.lua). Параметры и списки целей — mod-data "pd-fire-safety".
-- Каждая турель обслуживается раз в 2 с (турели разнесены по 12 слотам, чтобы не было пика в один тик).
-- Нет целей в зоне: дежурный расход воды (idle); если воды хватило, турель «активна» и
-- Flammable_Oils_QUICKFIX через remote "paranoidal_fire_safety" ничего не поджигает и не взрывает в зоне.
-- Есть цели: расход combat, до MAX_SHOTS струй воды. Огонь (в т. ч. кислота на земле) и вражеские облака
-- гаснут при попадании струи в радиусе HIT_RADIUS; вредные стикеры со своих снимаются сразу при планировании.
-- При полном запасе воды цели сверх лимита струй и цели в мёртвой зоне ствола гасятся сразу, без струи;
-- при нехватке — меньше струй.
--
-- Ствол рисуется здесь через rendering (у самой сущности он пустой: движок турели целей не видит) по
-- ванильному циклу огнемётной турели: сложен → выдвигается (цель ближе prepare_range) → наводится по
-- 64 положениям со скоростью rotation_speed → струя из дула, ствол держит прицел, пока течёт струя →
-- складывается, когда целей в prepare_range нет или кончилась вода. Каждый тик обрабатываются только
-- турели в движении (storage.fire_safety.moving). Состояние — только в storage.fire_safety.
local M = {}

local DATA = "pd-fire-safety"
local PERIOD = 120 -- тиков между обслуживаниями одной турели
local SLOTS = 12
local STEP = PERIOD / SLOTS
local MAX_SHOTS = 4 -- струй на турель за цикл
local HIT_RADIUS = 2.5 -- одна струя гасит всё в этом радиусе от точки попадания
local MAX_EFFECTS = 12 -- облачков пара на одно попадание / одно мгновенное тушение
local STREAM = "pd-fire-safety-stream"
local HIT = "pd-fire-safety-hit"
local STEAM = "pd-fire-safety-steam"
local SPLASH = "water-splash" -- всплеск воды из базовой игры
local ACTIVATE = "pd-fire-safety-activate"
local DEACTIVATE = "pd-fire-safety-deactivate"
local TARGET_TYPES = {"fire", "smoke-with-trigger", "sticker"}
local HIT_TYPES = {"fire", "smoke-with-trigger"}
local RENDER_LAYER = "object" -- как gun_animation_render_layer огнемётной турели
local GUN_FRAMES = 64

-- Геометрия ствола огнемётной турели (base/prototypes/entity/fire.lua, fireutil).
-- Сдвиг оси ствола от центра сущности по направлению корпуса (turret_gun_shift).
local GUN_SHIFT = {
	north = {0, -6 / 32},
	east = {18.5 / 32, 9.5 / 32},
	south = {0, 19 / 32},
	west = {-12 / 32, 5.5 / 32},
}
-- Кончик поднятого ствола относительно оси: turret_model_info.gun_tip_raised (4 единицы модели на клетку),
-- проекция как в math3d.project_vec3.
local TIP_REACH = 2.2515 / 4
local TIP_HEIGHT = 7.10942 / 4
local PROJECTION = 0.7071067811865

local DIRECTIONS = {
	[defines.direction.north] = "north",
	[defines.direction.east] = "east",
	[defines.direction.south] = "south",
	[defines.direction.west] = "west",
}

-- Кэш mod-data: прототипы в сессии не меняются.
local config
local function cfg()
	if config then return config end
	local mod_data = prototypes.mod_data[DATA]
	local d = mod_data and mod_data.data or {}
	local gun = d.gun or {}
	config = {tiers = {}, names = {}, max_range = 0, stickers = d.stickers or {}, clouds = d.clouds or {},
		splash = prototypes.entity[SPLASH] ~= nil,
		gun = {rotation_speed = gun.rotation_speed or 0.015, preparing_speed = gun.preparing_speed or 0.08,
			folding_speed = gun.folding_speed or 0.08, hold = gun.hold or 40,
			extension_frames = gun.extension_frames or 15}}
	for name, tier in pairs(d.tiers or {}) do
		-- Анимации ствола создаются в том же файле, что и mod-data (проверить их из control API нельзя).
		if prototypes.entity[name] and tier.gun and tier.extension then
			config.tiers[name] = {range = tier.range, turn_range = tier.turn_range,
				min_range = tier.min_range or 0, prepare_range = tier.prepare_range or tier.range,
				idle = tier.idle * PERIOD / 60, combat = tier.combat * PERIOD / 60,
				gun = tier.gun, extension = tier.extension}
			config.names[#config.names + 1] = name
			config.max_range = math.max(config.max_range, tier.range)
		end
	end
	return config
end

-- Вектор «вперёд» по направлению сущности (16 направлений, 0 = север).
local function forward(direction)
	local angle = (direction or 0) / 16 * 2 * math.pi
	return math.sin(angle), -math.cos(angle)
end

-- Точка в зоне турели: в пределах дальности и сектора turn_range вокруг направления.
local function in_zone(turret, tier, position)
	local tp = turret.position
	local dx, dy = position.x - tp.x, position.y - tp.y
	local distance = math.sqrt(dx * dx + dy * dy)
	if distance > tier.range then return false end
	if tier.turn_range >= 1 or distance < 0.5 then return true end
	local fx, fy = forward(turret.direction)
	return (dx * fx + dy * fy) / distance >= math.cos(tier.turn_range * math.pi)
end

local function state()
	local s = storage.fire_safety
	if not s then
		s = {turrets = {}, active = {}, moving = {}}
		storage.fire_safety = s
	end
	s.moving = s.moving or {}
	return s
end

-- Ствол ----------------------------------------------------------------------------------------------

local function direction_name(entity)
	return DIRECTIONS[entity.direction] or "north"
end

-- Ось ствола в мире.
local function gun_pivot(entity)
	local p = entity.position
	local shift = GUN_SHIFT[direction_name(entity)]
	return p.x + shift[1], p.y + shift[2]
end

-- Кадр листа ствола: 64 положения против часовой стрелки от севера (counterclockwise = true).
local function gun_frame(orientation)
	return (GUN_FRAMES - math.floor(orientation * GUN_FRAMES + 0.5)) % GUN_FRAMES
end

local function extension_frame(progress, c)
	return math.floor(progress * (c.gun.extension_frames - 1) + 0.5)
end

-- Показать текущее состояние ствола в уже созданном объекте rendering.
local function show(rec, tier, c)
	local render = rec.render
	if not (render and render.valid) then return end
	if rec.state == "prepared" then
		if render.animation ~= tier.gun then render.animation = tier.gun end
		render.animation_offset = gun_frame(rec.orientation)
	else
		local name = tier.extension[direction_name(rec.entity)]
		if render.animation ~= name then render.animation = name end
		render.animation_offset = extension_frame(rec.progress, c)
	end
end

-- (Пере)создать объект ствола; нужен при постройке, повороте корпуса и после смены конфигурации.
local function draw(rec, tier, c)
	local entity = rec.entity
	if rec.render and rec.render.valid then rec.render.destroy() end
	local shift = GUN_SHIFT[direction_name(entity)]
	rec.dir = entity.direction
	rec.render = rendering.draw_animation({
		animation = tier.extension[direction_name(entity)],
		animation_speed = 0,
		target = {entity = entity, offset = shift},
		surface = entity.surface,
		render_layer = RENDER_LAYER,
	})
	show(rec, tier, c)
end

local function ensure_drawn(rec, tier, c)
	if not (rec.render and rec.render.valid) or rec.dir ~= rec.entity.direction then draw(rec, tier, c) end
end

local function play(entity, path)
	entity.surface.play_sound({path = path, position = entity.position})
end

-- Нужно разложить ствол (есть цели в prepare_range).
local function wake(s, id, rec)
	if rec.state == "folded" or rec.state == "folding" then
		play(rec.entity, ACTIVATE)
		rec.state = "preparing"
		s.moving[id] = rec
	end
end

-- Целей нет или нет воды: сложить ствол.
local function sleep(s, id, rec)
	rec.queue = {}
	rec.hold = 0
	if rec.state == "prepared" or rec.state == "preparing" then
		play(rec.entity, DEACTIVATE)
		rec.state = "folding"
		s.moving[id] = rec
	end
end

local function new_record(entity)
	return {entity = entity, state = "folded", progress = 0, orientation = (entity.direction or 0) / 16,
		queue = {}, hold = 0}
end

-- До стволов на rendering в storage.fire_safety.turrets хранилась сама сущность.
local function record(s, id)
	local rec = s.turrets[id]
	if rec and rec.object_name then
		if not rec.valid then
			s.turrets[id] = nil
			s.active[id] = nil
			s.moving[id] = nil
			return nil
		end
		rec = new_record(rec)
		s.turrets[id] = rec
	end
	return rec
end

local function forget(s, id)
	local rec = s.turrets[id]
	if type(rec) == "table" and rec.render and rec.render.valid then rec.render.destroy() end
	s.turrets[id] = nil
	s.active[id] = nil
	s.moving[id] = nil
end

local function add(entity)
	local c = cfg()
	local tier = entity and entity.valid and c.tiers[entity.name]
	if not (tier and entity.unit_number) then return end
	local s = state()
	local rec = record(s, entity.unit_number)
	if not rec then
		rec = new_record(entity)
		s.turrets[entity.unit_number] = rec
	end
	draw(rec, tier, c)
end

-- on_init / on_configuration_changed: подобрать турели, построенные до появления модуля, перерисовать стволы.
function M.sync()
	local c = cfg()
	if #c.names == 0 then
		storage.fire_safety = nil
		return
	end
	local s = state()
	for id in pairs(s.turrets) do
		local rec = record(s, id)
		if rec and not (rec.entity.valid and c.tiers[rec.entity.name]) then forget(s, id) end
	end
	for _, surface in pairs(game.surfaces) do
		for _, entity in pairs(surface.find_entities_filtered({name = c.names})) do add(entity) end
	end
end

-- Тушение ---------------------------------------------------------------------------------------------

-- Цель для турели: любой огонь, вражеское облако, вредный стикер на своём или союзном.
local function is_target(entity, force, c)
	local kind = entity.type
	if kind == "fire" then return true end
	if kind == "smoke-with-trigger" then return c.clouds[entity.name] == true end
	if not c.stickers[entity.name] then return false end
	local host = entity.sticked_to
	if not (host and host.valid) then return false end
	local host_force = host.force
	return host_force == force or force.is_friend(host_force)
end

-- Убрать огонь/облако с паром; effects — сколько облачков уже создано в этом проходе.
local function neutralize(surface, entity, effects)
	local position = entity.position
	entity.destroy()
	if effects < MAX_EFFECTS then
		surface.create_trivial_smoke({name = STEAM,
			position = {position.x + math.random() - 0.5, position.y + math.random() - 0.5}})
	end
	return effects + 1
end

-- Струя из дула при текущем положении ствола.
local function shoot(rec, position)
	local entity = rec.entity
	local px, py = gun_pivot(entity)
	local phi = (rec.orientation - 0.25) * 2 * math.pi
	local from = {x = px + math.cos(phi) * TIP_REACH, y = py + (math.sin(phi) * TIP_REACH - TIP_HEIGHT) * PROJECTION}
	entity.surface.create_entity({name = STREAM, position = from, source_position = from, target_position = position})
end

-- Очередь выстрелов на цикл; budget = доля воды для тушения, полученная в этом цикле (0..1].
-- Цели ближе min_range ствол не достаёт: при полном запасе они гасятся сразу, как цели сверх лимита.
local function plan(turret, tier, targets, budget)
	local shots = budget >= 1 and MAX_SHOTS or math.max(1, math.floor(MAX_SHOTS * budget))
	local surface = turret.surface
	local tp = turret.position
	local min2 = tier.min_range * tier.min_range
	local r2 = HIT_RADIUS * HIT_RADIUS
	local covered, queue, effects = {}, {}, 0
	for i, target in ipairs(targets) do
		if not covered[i] and target.valid then
			local p = target.position
			local sticker = target.type == "sticker"
			local dx, dy = p.x - tp.x, p.y - tp.y
			if #queue < shots and dx * dx + dy * dy >= min2 then
				-- Соседи в радиусе попадания: огонь и облака погаснут от этой же струи, стикеры снимаются сейчас.
				for j = i + 1, #targets do
					local other = targets[j]
					if not covered[j] and other.valid then
						local q = other.position
						local ox, oy = q.x - p.x, q.y - p.y
						if ox * ox + oy * oy <= r2 then
							covered[j] = true
							if other.type == "sticker" then other.destroy() end
						end
					end
				end
				queue[#queue + 1] = {x = p.x, y = p.y, entity = not sticker and target or nil}
				if sticker then target.destroy() end
			elseif budget >= 1 then
				if sticker then
					target.destroy()
				else
					effects = neutralize(surface, target, effects)
				end
			end
		end
	end
	return queue
end

local function service(id, rec, tier, s, c)
	local turret = rec.entity
	ensure_drawn(rec, tier, c)
	if turret.get_fluid_count("water") < tier.idle then
		s.active[id] = nil
		sleep(s, id, rec)
		return
	end
	s.active[id] = true
	local targets, near = {}, false
	local force = turret.force
	local tp = turret.position
	for _, entity in pairs(turret.surface.find_entities_filtered({type = TARGET_TYPES, position = tp,
		radius = tier.prepare_range})) do
		if is_target(entity, force, c) then
			if in_zone(turret, tier, entity.position) then
				targets[#targets + 1] = entity
			else
				near = true
			end
		end
	end
	if #targets == 0 then
		turret.remove_fluid({name = "water", amount = tier.idle})
		if near then
			wake(s, id, rec)
			rec.queue = {}
		else
			sleep(s, id, rec)
		end
		return
	end
	wake(s, id, rec)
	local used = turret.remove_fluid({name = "water", amount = tier.combat})
	rec.queue = plan(turret, tier, targets, used / tier.combat)
	if #rec.queue > 0 then s.moving[id] = rec end
end

local function update(event)
	local s = storage.fire_safety
	if not s then return end
	s.moving = s.moving or {}
	local c = cfg()
	local slot = math.floor(event.tick / STEP) % SLOTS
	for id in pairs(s.turrets) do
		if id % SLOTS == slot then
			local rec = record(s, id)
			if rec then
				local tier = rec.entity.valid and c.tiers[rec.entity.name]
				if tier then
					service(id, rec, tier, s, c)
				else
					forget(s, id)
				end
			end
		end
	end
end

-- Один тик движения ствола; false — турель больше не нужно обрабатывать каждый тик.
local function step(rec, tier, c)
	local g = c.gun
	if rec.state == "preparing" then
		rec.progress = math.min(1, rec.progress + g.preparing_speed)
		if rec.progress >= 1 then rec.state = "prepared" end
		show(rec, tier, c)
		return true
	end
	if rec.state == "folding" then
		rec.progress = math.max(0, rec.progress - g.folding_speed)
		if rec.progress <= 0 then rec.state = "folded" end
		show(rec, tier, c)
		return rec.state == "folding"
	end
	if rec.state ~= "prepared" then return false end
	if rec.hold > 0 then -- струя ещё течёт: ствол держит прицел
		rec.hold = rec.hold - 1
		return true
	end
	local queue = rec.queue
	local target = queue[1]
	while target and target.entity and not target.entity.valid do -- уже погасло от соседней струи
		table.remove(queue, 1)
		target = queue[1]
	end
	if not target then return false end
	local px, py = gun_pivot(rec.entity)
	local desired = (math.atan2(target.x - px, py - target.y) / (2 * math.pi)) % 1
	local diff = (desired - rec.orientation + 0.5) % 1 - 0.5
	if math.abs(diff) <= g.rotation_speed then
		rec.orientation = desired
		show(rec, tier, c)
		shoot(rec, target)
		table.remove(queue, 1)
		rec.hold = g.hold
	else
		rec.orientation = (rec.orientation + (diff > 0 and g.rotation_speed or -g.rotation_speed)) % 1
		show(rec, tier, c)
	end
	return true
end

local function on_tick()
	local s = storage.fire_safety
	if not (s and s.moving and next(s.moving)) then return end
	local c = cfg()
	for id, rec in pairs(s.moving) do
		local entity = rec.entity
		local tier = entity.valid and c.tiers[entity.name]
		if not tier then
			forget(s, id)
		else
			ensure_drawn(rec, tier, c)
			if not step(rec, tier, c) then s.moving[id] = nil end
		end
	end
end

-- Корпус повернули/отразили: ствол сдвигается вместе с ним.
local function on_reoriented(e)
	local entity = e.entity
	if not (entity and entity.valid and entity.unit_number) then return end
	local c = cfg()
	local tier = c.tiers[entity.name]
	if not (storage.fire_safety and tier) then return end
	local s = state()
	local rec = record(s, entity.unit_number)
	if rec then draw(rec, tier, c) end
end

-- Первая капля струи долетела: всплеск, огонь и вражеские облака в радиусе гаснут.
local function on_hit(e)
	if e.effect_id ~= HIT then return end
	local surface = game.surfaces[e.surface_index]
	local position = e.target_position
	if not (surface and position) then return end
	local c = cfg()
	if c.splash then surface.create_entity({name = SPLASH, position = position}) end
	local effects = 0
	for _, entity in pairs(surface.find_entities_filtered({type = HIT_TYPES, position = position,
		radius = HIT_RADIUS})) do
		if entity.valid and (entity.type == "fire" or c.clouds[entity.name]) then
			effects = neutralize(surface, entity, effects)
		end
	end
end

-- true, если точка в зоне активной турели.
local function is_protected(surface, position)
	local s = storage.fire_safety
	if not (s and next(s.active) and surface and surface.valid and position) then return false end
	local c = cfg()
	position = {x = position.x or position[1], y = position.y or position[2]}
	for _, entity in pairs(surface.find_entities_filtered({name = c.names, position = position,
		radius = c.max_range})) do
		local tier = c.tiers[entity.name]
		if s.active[entity.unit_number] and tier and in_zone(entity, tier, position) then return true end
	end
	return false
end

-- Сохранить ранее зарегистрированные обработчики zzz, как в соседних модулях.
local function on(event, callback)
	local previous = script.get_event_handler(event)
	script.on_event(event, function(e)
		if previous then previous(e) end
		callback(e)
	end)
end

function M.install()
	remote.add_interface("paranoidal_fire_safety", {
		is_protected = is_protected,
		radius = function() return cfg().max_range end,
	})
	for _, event in ipairs({defines.events.on_built_entity, defines.events.on_robot_built_entity,
		defines.events.script_raised_built, defines.events.script_raised_revive}) do
		on(event, function(e) add(e.entity) end)
	end
	on(defines.events.on_entity_cloned, function(e) add(e.destination) end)
	on(defines.events.on_player_rotated_entity, on_reoriented)
	on(defines.events.on_player_flipped_entity, on_reoriented)
	on(defines.events.on_script_trigger_effect, on_hit)
	on(defines.events.on_tick, on_tick)
	script.on_nth_tick(STEP, update)
end

return M
