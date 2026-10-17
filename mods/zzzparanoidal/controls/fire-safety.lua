-- Пожарные турели (prototypes/fire-safety-turret.lua).
-- Каждые 2 с турель расходует воду; если воды хватило, она «активна»: гасит огонь в своей зоне
-- (облачко пара на месте огня), а Flammable_Oils_QUICKFIX через remote "paranoidal_fire_safety"
-- не поджигает и не взрывает ничего в этой зоне. Зона: дальность и сектор вперёд (доля круга),
-- как у огнемётной турели. Состояние — только в storage.fire_safety.
local M = {}

-- Держать равными prototypes/fire-safety-turret.lua.
local TIERS = {
	["pd-fire-safety-turret"] = {range = 12, turn_range = 1, water = 10},
	["pd-fire-safety-turret-mk2"] = {range = 24, turn_range = 1, water = 20},
}
local MAX_RANGE = 24
local PERIOD = 120 -- тиков
local STEAM = "pd-fire-safety-steam"
local SPLASH = "water-splash" -- всплеск воды из базовой игры

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

local function names()
	local list = {}
	for name in pairs(TIERS) do
		if prototypes.entity[name] then list[#list + 1] = name end
	end
	return list
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
	if entity and entity.valid and TIERS[entity.name] and entity.unit_number then
		state().turrets[entity.unit_number] = entity
	end
end

-- on_init / on_configuration_changed: подобрать турели, построенные до появления модуля.
function M.sync()
	local list = names()
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

local function extinguish(entity, tier)
	local surface = entity.surface
	for _, fire in pairs(surface.find_entities_filtered({type = "fire", position = entity.position, radius = tier.range})) do
		if fire.valid and in_zone(entity, tier, fire.position) then
			local position = fire.position
			fire.destroy()
			if prototypes.entity[SPLASH] then surface.create_entity({name = SPLASH, position = position}) end
			for _ = 1, 3 do
				surface.create_trivial_smoke({name = STEAM,
					position = {position.x + math.random() - 0.5, position.y + math.random() - 0.5}})
			end
		end
	end
end

local function update()
	local s = storage.fire_safety
	if not s then return end
	for id, entity in pairs(s.turrets) do
		local tier = entity.valid and TIERS[entity.name]
		if not tier then
			s.turrets[id] = nil
			s.active[id] = nil
		elseif entity.remove_fluid({name = "water", amount = tier.water}) >= tier.water then
			s.active[id] = true
			extinguish(entity, tier)
		else
			s.active[id] = nil
		end
	end
end

-- true, если точка в зоне активной турели.
local function is_protected(surface, position)
	local s = storage.fire_safety
	if not (s and next(s.active) and surface and surface.valid and position) then return false end
	position = {x = position.x or position[1], y = position.y or position[2]}
	for _, entity in pairs(surface.find_entities_filtered({name = names(), position = position, radius = MAX_RANGE})) do
		local tier = TIERS[entity.name]
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
		radius = function() return MAX_RANGE end,
	})
	for _, event in ipairs({defines.events.on_built_entity, defines.events.on_robot_built_entity,
		defines.events.script_raised_built, defines.events.script_raised_revive}) do
		on(event, function(e) add(e.entity) end)
	end
	on(defines.events.on_entity_cloned, function(e) add(e.destination) end)
	script.on_nth_tick(PERIOD, update)
end

return M
