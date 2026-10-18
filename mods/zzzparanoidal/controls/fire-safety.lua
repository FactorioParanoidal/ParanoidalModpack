-- Пожарные турели (prototypes/fire-safety-turret.lua). Параметры и списки целей — mod-data "pd-fire-safety".
-- Каждая турель обслуживается раз в 2 с (турели разнесены по 12 слотам, чтобы не было пика в один тик).
-- Нет целей в зоне: дежурный расход воды (idle); если воды хватило, турель «активна» и
-- Flammable_Oils_QUICKFIX через remote "paranoidal_fire_safety" ничего не поджигает и не взрывает в зоне.
-- Есть цели: расход combat, до MAX_SHOTS струй воды. Огонь (в т. ч. кислота на земле) и вражеские облака
-- гаснут при попадании струи в радиусе HIT_RADIUS; вредные стикеры со своих снимаются сразу при выстреле.
-- При полном запасе воды цели сверх лимита струй гасятся сразу, без струи; при нехватке — меньше струй.
-- Состояние — только в storage.fire_safety.
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
local TARGET_TYPES = {"fire", "smoke-with-trigger", "sticker"}
local HIT_TYPES = {"fire", "smoke-with-trigger"}

-- Кэш mod-data: прототипы в сессии не меняются.
local config
local function cfg()
	if config then return config end
	local mod_data = prototypes.mod_data[DATA]
	local d = mod_data and mod_data.data or {}
	config = {tiers = {}, names = {}, max_range = 0, stickers = d.stickers or {}, clouds = d.clouds or {},
		splash = prototypes.entity[SPLASH] ~= nil}
	for name, tier in pairs(d.tiers or {}) do
		if prototypes.entity[name] then
			config.tiers[name] = {range = tier.range, turn_range = tier.turn_range,
				idle = tier.idle * PERIOD / 60, combat = tier.combat * PERIOD / 60}
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
		s = {turrets = {}, active = {}}
		storage.fire_safety = s
	end
	return s
end

local function add(entity)
	if entity and entity.valid and cfg().tiers[entity.name] and entity.unit_number then
		state().turrets[entity.unit_number] = entity
	end
end

-- on_init / on_configuration_changed: подобрать турели, построенные до появления модуля.
function M.sync()
	local list = cfg().names
	if #list == 0 then
		storage.fire_safety = nil
		return
	end
	local s = state()
	for id, entity in pairs(s.turrets) do
		if not entity.valid then
			s.turrets[id] = nil
			s.active[id] = nil
		end
	end
	for _, surface in pairs(game.surfaces) do
		for _, entity in pairs(surface.find_entities_filtered({name = list})) do add(entity) end
	end
end

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

local function shoot(turret, position, aim)
	local tp = turret.position
	local dx, dy = position.x - tp.x, position.y - tp.y
	local distance = math.sqrt(dx * dx + dy * dy)
	if aim then
		-- Повернуть ствол к первой цели (у сложенной турели может быть не видно).
		pcall(function() turret.orientation = (math.atan2(dx, -dy) / (2 * math.pi)) % 1 end)
	end
	local k = distance > 1.5 and 1.2 / distance or 0
	local from = {x = tp.x + dx * k, y = tp.y + dy * k}
	turret.surface.create_entity({name = STREAM, position = from, source_position = from, target_position = position})
end

-- budget = доля воды для тушения, полученная в этом цикле (0..1].
local function fire_at(turret, targets, budget)
	local shots = budget >= 1 and MAX_SHOTS or math.max(1, math.floor(MAX_SHOTS * budget))
	local surface = turret.surface
	local covered = {}
	local fired, effects = 0, 0
	local r2 = HIT_RADIUS * HIT_RADIUS
	for i, target in ipairs(targets) do
		if not covered[i] and target.valid then
			if fired < shots then
				fired = fired + 1
				local p = target.position
				-- Соседи в радиусе попадания: огонь и облака погаснут от этой же струи, стикеры снимаются сейчас.
				for j = i + 1, #targets do
					local other = targets[j]
					if not covered[j] and other.valid then
						local q = other.position
						local dx, dy = q.x - p.x, q.y - p.y
						if dx * dx + dy * dy <= r2 then
							covered[j] = true
							if other.type == "sticker" then other.destroy() end
						end
					end
				end
				shoot(turret, p, fired == 1)
				if target.type == "sticker" then target.destroy() end
			elseif budget >= 1 then
				if target.type == "sticker" then
					target.destroy()
				else
					effects = neutralize(surface, target, effects)
				end
			else
				return
			end
		end
	end
end

local function service(id, turret, tier, s, c)
	if turret.get_fluid_count("water") < tier.idle then
		s.active[id] = nil
		return
	end
	s.active[id] = true
	local targets = {}
	local force = turret.force
	for _, entity in pairs(turret.surface.find_entities_filtered({type = TARGET_TYPES, position = turret.position,
		radius = tier.range})) do
		if is_target(entity, force, c) and in_zone(turret, tier, entity.position) then targets[#targets + 1] = entity end
	end
	if #targets == 0 then
		turret.remove_fluid({name = "water", amount = tier.idle})
		return
	end
	local used = turret.remove_fluid({name = "water", amount = tier.combat})
	fire_at(turret, targets, used / tier.combat)
end

local function update(event)
	local s = storage.fire_safety
	if not s then return end
	local c = cfg()
	local slot = math.floor(event.tick / STEP) % SLOTS
	for id, entity in pairs(s.turrets) do
		if id % SLOTS == slot then
			local tier = entity.valid and c.tiers[entity.name]
			if tier then
				service(id, entity, tier, s, c)
			else
				s.turrets[id] = nil
				s.active[id] = nil
			end
		end
	end
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
	on(defines.events.on_script_trigger_effect, on_hit)
	script.on_nth_tick(STEP, update)
end

return M
